package com.cyberguard.xai.core.deepfake

import android.graphics.Bitmap
import android.graphics.RectF
import com.cyberguard.xai.presentation.components.RiskSeverity

enum class DeepfakeMediaType {
    IMAGE,
    VIDEO,
    AUDIO
}

data class MediaValidationResult(
    val isValid: Boolean,
    val mediaType: DeepfakeMediaType?,
    val fileName: String,
    val fileSize: Long,
    val mimeType: String,
    val durationMs: Long? = null,
    val errorMessage: String? = null
)

data class ExtractedFrame(
    val frameIndex: Int,
    val timestampMs: Long,
    val bitmap: Bitmap?,
    val width: Int,
    val height: Int
)

data class DetectedFace(
    val frameIndex: Int,
    val boundingBox: RectF,
    val confidence: Float,
    val eyeDistance: Float,
    val hasValidLandmarks: Boolean = true
)

data class ForensicAnomaly(
    val title: String,
    val category: String,
    val severity: RiskSeverity,
    val description: String,
    val metricValue: String
)

data class DeepfakeModelInput(
    val mediaType: DeepfakeMediaType,
    val fileName: String,
    val fileSize: Long,
    val durationMs: Long?,
    val extractedFrames: List<ExtractedFrame>,
    val detectedFaces: List<DetectedFace>,
    val totalFramesAnalyzed: Int
)

data class DeepfakeModelOutput(
    val isSynthetic: Boolean,
    val syntheticLikelihood: Float,     // 0.0 to 100.0%
    val confidence: Float,              // 0.0 to 1.0 (prototype confidence based on quality/evidence)
    val riskScore: Int,                 // 0 to 100
    val severity: RiskSeverity,
    val detectedAnomalies: List<ForensicAnomaly>,
    val explanation: String,
    val countermeasureAdvisory: String,
    val modelIdentifier: String,
    val isPrototypeAnalysis: Boolean = true
)

sealed class DeepfakePipelineStage {
    data object Idle : DeepfakePipelineStage()
    data class ValidatingMedia(val fileName: String) : DeepfakePipelineStage()
    data class ExtractingFrames(val current: Int, val total: Int) : DeepfakePipelineStage()
    data class DetectingFaces(val facesFound: Int) : DeepfakePipelineStage()
    data class RunningInference(val modelName: String) : DeepfakePipelineStage()
    data class Completed(val output: DeepfakeModelOutput) : DeepfakePipelineStage()
    data class Failed(val reason: String) : DeepfakePipelineStage()
}
