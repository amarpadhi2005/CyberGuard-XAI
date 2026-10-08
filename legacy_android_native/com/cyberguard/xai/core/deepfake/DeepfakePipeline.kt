package com.cyberguard.xai.core.deepfake

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.PointF
import android.graphics.RectF
import android.media.FaceDetector
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.OpenableColumns
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import java.io.InputStream

/**
 * End-to-end Deepfake Detection Pipeline Orchestrator:
 * media validation -> frame extraction -> face detection -> model inference -> confidence / risk / XAI
 */
class DeepfakePipeline(
    private val context: Context,
    private val model: DeepfakeDetectionModel = PrototypeHeuristicDeepfakeModel()
) {

    private val contentResolver = context.contentResolver

    /**
     * Executes the full pipeline on a user-uploaded media URI and emits progress stages.
     */
    fun processMedia(uri: Uri): Flow<DeepfakePipelineStage> = flow {
        emit(DeepfakePipelineStage.Idle)

        // 1. Media Validation
        val validation = validateMedia(uri)
        if (!validation.isValid || validation.mediaType == null) {
            emit(DeepfakePipelineStage.Failed(validation.errorMessage ?: "Media validation failed"))
            return@flow
        }
        emit(DeepfakePipelineStage.ValidatingMedia(validation.fileName))

        // 2. Frame Extraction
        val extractedFrames = try {
            when (validation.mediaType) {
                DeepfakeMediaType.IMAGE -> extractFramesFromImage(uri)
                DeepfakeMediaType.VIDEO -> extractFramesFromVideo(uri, validation.durationMs ?: 5000L)
                DeepfakeMediaType.AUDIO -> emptyList()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Frame extraction error: ${e.message}", e)
            emit(DeepfakePipelineStage.Failed("Failed to extract frames: ${e.message}"))
            return@flow
        }

        emit(DeepfakePipelineStage.ExtractingFrames(extractedFrames.size, extractedFrames.size))

        // 3. Face Detection
        val detectedFaces = mutableListOf<DetectedFace>()
        if (validation.mediaType != DeepfakeMediaType.AUDIO) {
            extractedFrames.forEach { frame ->
                frame.bitmap?.let { bmp ->
                    val faces = detectFacesInBitmap(bmp, frame.frameIndex)
                    detectedFaces.addAll(faces)
                }
            }
        }
        emit(DeepfakePipelineStage.DetectingFaces(detectedFaces.size))

        // 4. Model Inference Interface
        emit(DeepfakePipelineStage.RunningInference(model.modelName))

        val modelInput = DeepfakeModelInput(
            mediaType = validation.mediaType,
            fileName = validation.fileName,
            fileSize = validation.fileSize,
            durationMs = validation.durationMs,
            extractedFrames = extractedFrames,
            detectedFaces = detectedFaces,
            totalFramesAnalyzed = extractedFrames.size
        )

        val output = model.infer(modelInput)

        // 5. Output: Confidence, Risk Score, Explanation
        emit(DeepfakePipelineStage.Completed(output))
    }.flowOn(Dispatchers.IO)

    /**
     * Step 1: Media Validation
     * Validates mime type, file size (<= 35MB), and duration (<= 60 seconds for video).
     */
    fun validateMedia(uri: Uri): MediaValidationResult {
        var fileName = "unknown_media"
        var fileSize = 0L

        try {
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (cursor.moveToFirst()) {
                    if (nameIndex != -1) fileName = cursor.getString(nameIndex) ?: fileName
                    if (sizeIndex != -1) fileSize = cursor.getLong(sizeIndex)
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not query content provider: ${e.message}")
        }

        val mimeType = contentResolver.getType(uri)?.lowercase() ?: getMimeTypeFromFileName(fileName)

        val mediaType = when {
            mimeType.startsWith("image/") -> DeepfakeMediaType.IMAGE
            mimeType.startsWith("video/") -> DeepfakeMediaType.VIDEO
            mimeType.startsWith("audio/") -> DeepfakeMediaType.AUDIO
            else -> null
        }

        if (mediaType == null) {
            return MediaValidationResult(
                isValid = false,
                mediaType = null,
                fileName = fileName,
                fileSize = fileSize,
                mimeType = mimeType,
                errorMessage = "Unsupported file type: $mimeType. Please upload an Image (JPG/PNG/WEBP) or Video (MP4/MKV)."
            )
        }

        // Validate max size: 35MB
        val maxSizeBytes = 35 * 1024 * 1024L
        if (fileSize > maxSizeBytes) {
            return MediaValidationResult(
                isValid = false,
                mediaType = mediaType,
                fileName = fileName,
                fileSize = fileSize,
                mimeType = mimeType,
                errorMessage = "File size exceeds 35MB limit. Please upload a smaller sample."
            )
        }

        // Validate duration for video
        var durationMs: Long? = null
        if (mediaType == DeepfakeMediaType.VIDEO) {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(context, uri)
                val durStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                durationMs = durStr?.toLongOrNull() ?: 5000L

                // Max duration 60 seconds for prototype analysis
                if (durationMs > 60_000L) {
                    return MediaValidationResult(
                        isValid = false,
                        mediaType = mediaType,
                        fileName = fileName,
                        fileSize = fileSize,
                        mimeType = mimeType,
                        durationMs = durationMs,
                        errorMessage = "Video length exceeds 60 seconds limit for prototype analysis."
                    )
                }
            } catch (e: Exception) {
                Log.w(TAG, "Could not extract video duration: ${e.message}")
                durationMs = 5000L
            } finally {
                try { retriever.release() } catch (_: Exception) {}
            }
        }

        return MediaValidationResult(
            isValid = true,
            mediaType = mediaType,
            fileName = fileName,
            fileSize = fileSize,
            mimeType = mimeType,
            durationMs = durationMs
        )
    }

    /**
     * Step 2a: Frame Extraction for Images
     */
    private fun extractFramesFromImage(uri: Uri): List<ExtractedFrame> {
        val inputStream: InputStream? = contentResolver.openInputStream(uri)
        val original = BitmapFactory.decodeStream(inputStream)
        inputStream?.close()

        if (original == null) {
            throw IllegalArgumentException("Could not decode image bitmap from uri")
        }

        // Downsample to max dimension 640 for rapid forensic evaluation
        val maxDim = 640
        val scale = Math.min(1.0f, maxDim.toFloat() / Math.max(original.width, original.height))
        val scaledWidth = (original.width * scale).toInt().coerceAtLeast(1)
        val scaledHeight = (original.height * scale).toInt().coerceAtLeast(1)

        val scaledBmp = Bitmap.createScaledBitmap(original, scaledWidth, scaledHeight, true)

        return listOf(
            ExtractedFrame(
                frameIndex = 0,
                timestampMs = 0L,
                bitmap = scaledBmp,
                width = scaledBmp.width,
                height = scaledBmp.height
            )
        )
    }

    /**
     * Step 2b: Frame Extraction for Videos
     * Extracts 4 evenly distributed keyframes across the duration.
     */
    private fun extractFramesFromVideo(uri: Uri, durationMs: Long): List<ExtractedFrame> {
        val retriever = MediaMetadataRetriever()
        val frames = mutableListOf<ExtractedFrame>()

        try {
            retriever.setDataSource(context, uri)
            val numFrames = 4
            val step = durationMs / (numFrames + 1)

            for (i in 1..numFrames) {
                val timeUs = (i * step) * 1000L
                val frameBmp = retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                if (frameBmp != null) {
                    val maxDim = 480
                    val scale = Math.min(1.0f, maxDim.toFloat() / Math.max(frameBmp.width, frameBmp.height))
                    val scaled = Bitmap.createScaledBitmap(
                        frameBmp,
                        (frameBmp.width * scale).toInt().coerceAtLeast(1),
                        (frameBmp.height * scale).toInt().coerceAtLeast(1),
                        true
                    )
                    frames.add(
                        ExtractedFrame(
                            frameIndex = i - 1,
                            timestampMs = i * step,
                            bitmap = scaled,
                            width = scaled.width,
                            height = scaled.height
                        )
                    )
                }
            }
        } finally {
            try { retriever.release() } catch (_: Exception) {}
        }

        return frames
    }

    /**
     * Step 3: Face Detection
     * Uses Android's built-in FaceDetector API.
     */
    private fun detectFacesInBitmap(bitmap: Bitmap, frameIndex: Int): List<DetectedFace> {
        val detected = mutableListOf<DetectedFace>()
        try {
            // Android FaceDetector requires Bitmap.Config.RGB_565 and even width
            val width = if (bitmap.width % 2 == 0) bitmap.width else bitmap.width - 1
            val height = bitmap.height
            if (width <= 0 || height <= 0) return emptyList()

            val rgb565Bmp = bitmap.copy(Bitmap.Config.RGB_565, true)
            val maxFaces = 3
            val faceDetector = FaceDetector(width, height, maxFaces)
            val facesArray = arrayOfNulls<FaceDetector.Face>(maxFaces)
            val facesFound = faceDetector.findFaces(rgb565Bmp, facesArray)

            for (i in 0 until facesFound) {
                val face = facesArray[i] ?: continue
                val midPoint = PointF()
                face.getMidPoint(midPoint)
                val eyeDistance = face.eyesDistance()
                val confidence = face.confidence()

                // Approximate bounding box around face
                val halfWidth = (eyeDistance * 1.5f) / width
                val halfHeight = (eyeDistance * 1.8f) / height
                val normX = midPoint.x / width
                val normY = midPoint.y / height

                val rect = RectF(
                    (normX - halfWidth).coerceIn(0f, 1f),
                    (normY - halfHeight).coerceIn(0f, 1f),
                    (normX + halfWidth).coerceIn(0f, 1f),
                    (normY + halfHeight).coerceIn(0f, 1f)
                )

                detected.add(
                    DetectedFace(
                        frameIndex = frameIndex,
                        boundingBox = rect,
                        confidence = confidence,
                        eyeDistance = eyeDistance
                    )
                )
            }
        } catch (e: Exception) {
            Log.w(TAG, "Face detection notice: ${e.message}")
        }
        return detected
    }

    private fun getMimeTypeFromFileName(fileName: String): String {
        val ext = fileName.substringAfterLast('.', "").lowercase()
        return when (ext) {
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "webp" -> "image/webp"
            "mp4" -> "video/mp4"
            "mkv" -> "video/x-matroska"
            "mov" -> "video/quicktime"
            "wav" -> "audio/wav"
            "mp3" -> "audio/mpeg"
            else -> "application/octet-stream"
        }
    }

    companion object {
        private const val TAG = "DeepfakePipeline"
    }
}
