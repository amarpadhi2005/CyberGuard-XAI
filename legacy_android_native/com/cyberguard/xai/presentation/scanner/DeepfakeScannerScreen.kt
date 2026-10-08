package com.cyberguard.xai.presentation.scanner

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.FileUpload
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Science
import androidx.compose.material.icons.filled.Videocam
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.deepfake.DeepfakeMediaType
import com.cyberguard.xai.core.deepfake.DeepfakeModelInput
import com.cyberguard.xai.core.deepfake.DeepfakeModelOutput
import com.cyberguard.xai.core.deepfake.DeepfakePipeline
import com.cyberguard.xai.core.deepfake.DeepfakePipelineStage
import com.cyberguard.xai.core.deepfake.DetectedFace
import com.cyberguard.xai.core.deepfake.ExtractedFrame
import com.cyberguard.xai.core.deepfake.PrototypeHeuristicDeepfakeModel
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.core.theme.RiskWarning
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.RiskBadge
import com.cyberguard.xai.presentation.components.RiskSeverity
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun DeepfakeScannerScreen() {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    var selectedTab by remember { mutableStateOf(DeepfakeMediaType.IMAGE) }
    var selectedFileUri by remember { mutableStateOf<Uri?>(null) }
    var selectedFileName by remember { mutableStateOf<String?>(null) }
    var pipelineStage by remember { mutableStateOf<DeepfakePipelineStage>(DeepfakePipelineStage.Idle) }
    var pipelineOutput by remember { mutableStateOf<DeepfakeModelOutput?>(null) }
    var pipelineError by remember { mutableStateOf<String?>(null) }

    val pipeline = remember { DeepfakePipeline(context) }

    // System File Pickers for Image, Video, and Audio
    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedFileUri = uri
            selectedFileName = uri.lastPathSegment ?: "uploaded_image.jpg"
            pipelineOutput = null
            pipelineError = null
            pipelineStage = DeepfakePipelineStage.Idle
        }
    }

    val videoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedFileUri = uri
            selectedFileName = uri.lastPathSegment ?: "uploaded_video.mp4"
            pipelineOutput = null
            pipelineError = null
            pipelineStage = DeepfakePipelineStage.Idle
        }
    }

    val audioPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedFileUri = uri
            selectedFileName = uri.lastPathSegment ?: "uploaded_audio.wav"
            pipelineOutput = null
            pipelineError = null
            pipelineStage = DeepfakePipelineStage.Idle
        }
    }

    fun runPipelineOnUri(uri: Uri) {
        pipelineError = null
        pipelineOutput = null
        coroutineScope.launch {
            pipeline.processMedia(uri).collect { stage ->
                pipelineStage = stage
                when (stage) {
                    is DeepfakePipelineStage.Completed -> {
                        pipelineOutput = stage.output
                    }
                    is DeepfakePipelineStage.Failed -> {
                        pipelineError = stage.reason
                    }
                    else -> Unit
                }
            }
        }
    }

    // Helper to run simulated sample benchmark (ideal for emulator/offline quick testing)
    fun runSampleBenchmark(type: DeepfakeMediaType) {
        pipelineError = null
        pipelineOutput = null
        coroutineScope.launch {
            pipelineStage = DeepfakePipelineStage.ValidatingMedia(
                when (type) {
                    DeepfakeMediaType.IMAGE -> "sample_synthetic_avatar.png"
                    DeepfakeMediaType.VIDEO -> "sample_face_swap_short.mp4"
                    DeepfakeMediaType.AUDIO -> "sample_cloned_voicemail.wav"
                }
            )
            delay(500)

            val frameCount = if (type == DeepfakeMediaType.VIDEO) 4 else 1
            pipelineStage = DeepfakePipelineStage.ExtractingFrames(frameCount, frameCount)
            delay(600)

            val faceCount = if (type != DeepfakeMediaType.AUDIO) 1 else 0
            pipelineStage = DeepfakePipelineStage.DetectingFaces(faceCount)
            delay(500)

            val model = PrototypeHeuristicDeepfakeModel()
            pipelineStage = DeepfakePipelineStage.RunningInference(model.modelName)
            delay(600)

            val mockInput = DeepfakeModelInput(
                mediaType = type,
                fileName = when (type) {
                    DeepfakeMediaType.IMAGE -> "sample_synthetic_avatar.png"
                    DeepfakeMediaType.VIDEO -> "sample_face_swap_short.mp4"
                    DeepfakeMediaType.AUDIO -> "sample_cloned_voicemail.wav"
                },
                fileSize = 1_420_000L,
                durationMs = if (type == DeepfakeMediaType.VIDEO) 8_000L else null,
                extractedFrames = (1..frameCount).map { idx ->
                    ExtractedFrame(idx - 1, (idx * 2000L), null, 640, 480)
                },
                detectedFaces = if (faceCount > 0) listOf(
                    DetectedFace(
                        frameIndex = 0,
                        boundingBox = android.graphics.RectF(0.2f, 0.15f, 0.8f, 0.85f),
                        confidence = 0.92f,
                        eyeDistance = 140f
                    )
                ) else emptyList(),
                totalFramesAnalyzed = frameCount
            )

            val result = model.infer(mockInput)
            pipelineOutput = result
            pipelineStage = DeepfakePipelineStage.Completed(result)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Prototype Banner
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(RiskWarning.copy(alpha = 0.12f))
                .border(1.dp, RiskWarning.copy(alpha = 0.4f), RoundedCornerShape(10.dp))
                .padding(horizontal = 12.dp, vertical = 8.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Science,
                    contentDescription = null,
                    tint = RiskWarning,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "PROTOTYPE ANALYSIS • Pluggable Inference Engine",
                    color = RiskWarning,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.5.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Media Type Selector: Image vs Video vs Audio
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(CyberCard)
                .border(1.dp, CyberCardBorder, RoundedCornerShape(12.dp))
                .padding(4.dp)
        ) {
            listOf(
                Triple(DeepfakeMediaType.IMAGE, "Image", Icons.Default.Image),
                Triple(DeepfakeMediaType.VIDEO, "Short Video", Icons.Default.Videocam),
                Triple(DeepfakeMediaType.AUDIO, "Voice Note", Icons.Default.GraphicEq)
            ).forEach { (type, label, icon) ->
                val isSelected = selectedTab == type
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(
                            if (isSelected) CyberCyan.copy(alpha = 0.22f) else Color.Transparent
                        )
                        .clickable {
                            selectedTab = type
                            selectedFileUri = null
                            selectedFileName = null
                            pipelineOutput = null
                            pipelineError = null
                            pipelineStage = DeepfakePipelineStage.Idle
                        }
                        .padding(vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = icon,
                            contentDescription = null,
                            tint = if (isSelected) CyberCyan else CyberTextMuted,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = label,
                            color = if (isSelected) CyberCyan else CyberTextMuted,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Upload & Inspection Card
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(
                    imageVector = when (selectedTab) {
                        DeepfakeMediaType.IMAGE -> Icons.Default.Image
                        DeepfakeMediaType.VIDEO -> Icons.Default.Videocam
                        DeepfakeMediaType.AUDIO -> Icons.Default.GraphicEq
                    },
                    contentDescription = null,
                    tint = CyberCyan,
                    modifier = Modifier.size(44.dp)
                )

                Spacer(modifier = Modifier.height(10.dp))

                Text(
                    text = when (selectedTab) {
                        DeepfakeMediaType.IMAGE -> "Upload Face Image for Forensic Inspection"
                        DeepfakeMediaType.VIDEO -> "Upload Short Video (Max 60s)"
                        DeepfakeMediaType.AUDIO -> "Inspect Synthetic Voice Audio"
                    },
                    color = CyberText,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = "Pipeline: Media Validation → Frame Extraction → Face Detection → Pluggable Model Inference",
                    color = CyberTextMuted,
                    fontSize = 10.sp,
                    textAlign = TextAlign.Center,
                    lineHeight = 14.sp
                )

                Spacer(modifier = Modifier.height(16.dp))

                // File Upload Button
                GradientButton(
                    text = if (selectedFileName != null) "CHANGE FILE: $selectedFileName" else "SELECT FROM DEVICE",
                    onClick = {
                        when (selectedTab) {
                            DeepfakeMediaType.IMAGE -> imagePickerLauncher.launch("image/*")
                            DeepfakeMediaType.VIDEO -> videoPickerLauncher.launch("video/*")
                            DeepfakeMediaType.AUDIO -> audioPickerLauncher.launch("audio/*")
                        }
                    },
                    height = 42.dp,
                    gradientColors = listOf(CyberCyan, CyberPink)
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Run Forensic Pipeline Button
                val isProcessing = pipelineStage !is DeepfakePipelineStage.Idle &&
                        pipelineStage !is DeepfakePipelineStage.Completed &&
                        pipelineStage !is DeepfakePipelineStage.Failed

                GradientButton(
                    text = "RUN FORENSIC PIPELINE",
                    onClick = {
                        val uri = selectedFileUri
                        if (uri != null) {
                            runPipelineOnUri(uri)
                        } else {
                            runSampleBenchmark(selectedTab)
                        }
                    },
                    isLoading = isProcessing,
                    height = 44.dp
                )

                if (selectedFileUri == null) {
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "(No file selected? Runs integrated prototype test sample)",
                        color = CyberTextMuted,
                        fontSize = 10.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Live Pipeline Execution Steps
        if (pipelineStage !is DeepfakePipelineStage.Idle) {
            CyberCard(modifier = Modifier.fillMaxWidth()) {
                Column {
                    Text(
                        text = "FORENSIC PIPELINE EXECUTION",
                        color = CyberCyan,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    PipelineStepRow(
                        title = "1. Media Validation",
                        subtitle = "Checks file signature, MIME type, size limit, and duration",
                        isActive = pipelineStage is DeepfakePipelineStage.ValidatingMedia,
                        isDone = pipelineStage !is DeepfakePipelineStage.ValidatingMedia && pipelineError == null
                    )

                    PipelineStepRow(
                        title = "2. Frame Extraction",
                        subtitle = "Decodes visual keyframes via MediaMetadataRetriever",
                        isActive = pipelineStage is DeepfakePipelineStage.ExtractingFrames,
                        isDone = (pipelineStage is DeepfakePipelineStage.DetectingFaces ||
                                pipelineStage is DeepfakePipelineStage.RunningInference ||
                                pipelineStage is DeepfakePipelineStage.Completed)
                    )

                    PipelineStepRow(
                        title = "3. Face Detection & ROI",
                        subtitle = "Identifies facial boundaries, landmarks, and ocular distance",
                        isActive = pipelineStage is DeepfakePipelineStage.DetectingFaces,
                        isDone = (pipelineStage is DeepfakePipelineStage.RunningInference ||
                                pipelineStage is DeepfakePipelineStage.Completed)
                    )

                    PipelineStepRow(
                        title = "4. Pluggable Model Inference",
                        subtitle = "Evaluates neural seam blending and temporal coherence",
                        isActive = pipelineStage is DeepfakePipelineStage.RunningInference,
                        isDone = pipelineStage is DeepfakePipelineStage.Completed
                    )

                    if (pipelineError != null) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "❌ Error: $pipelineError",
                            color = RiskCritical,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }

        // Forensic Results Card
        pipelineOutput?.let { res ->
            CyberCard(
                modifier = Modifier.fillMaxWidth(),
                borderColor = if (res.isSynthetic) RiskCritical.copy(alpha = 0.6f) else RiskSafe.copy(alpha = 0.6f)
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = if (res.isSynthetic) "SYNTHETIC DEEPFAKE DETECTED" else "BENIGN ORGANIC MEDIA",
                                    color = if (res.isSynthetic) RiskCritical else RiskSafe,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.ExtraBold
                                )
                            }
                            Text(
                                text = "Prototype Analysis",
                                color = RiskWarning,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        RiskBadge(severity = res.severity)
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Risk Score: ${res.riskScore}/100",
                            color = if (res.isSynthetic) RiskCritical else RiskSafe,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Confidence: ${(res.confidence * 100).toInt()}%",
                            color = CyberCyan,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    LinearProgressIndicator(
                        progress = { res.riskScore / 100f },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = if (res.isSynthetic) RiskCritical else RiskSafe,
                        trackColor = CyberCardBorder
                    )

                    Spacer(modifier = Modifier.height(14.dp))

                    Text(
                        text = "Forensic Anomalies & Evidence:",
                        color = CyberText,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    res.detectedAnomalies.forEach { anomaly ->
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(CyberCardBorder.copy(alpha = 0.3f))
                                .padding(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(
                                    text = anomaly.title,
                                    color = if (anomaly.severity != RiskSeverity.LOW) RiskCritical else RiskSafe,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = anomaly.metricValue,
                                    color = CyberTextMuted,
                                    fontSize = 10.sp
                                )
                            }
                            Text(
                                text = anomaly.description,
                                color = CyberTextMuted,
                                fontSize = 10.sp,
                                lineHeight = 14.sp
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "Explainable AI (XAI) Insight:",
                        color = CyberCyan,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = res.explanation,
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    Text(
                        text = "Countermeasure Advisory:",
                        color = CyberPink,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = res.countermeasureAdvisory,
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "Model: ${res.modelIdentifier}",
                        color = CyberTextMuted,
                        fontSize = 9.sp
                    )
                }
            }
        }
    }
}

@Composable
private fun PipelineStepRow(
    title: String,
    subtitle: String,
    isActive: Boolean,
    isDone: Boolean
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (isActive) {
            CircularProgressIndicator(
                modifier = Modifier.size(16.dp),
                strokeWidth = 2.dp,
                color = CyberCyan
            )
        } else if (isDone) {
            Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = null,
                tint = RiskSafe,
                modifier = Modifier.size(16.dp)
            )
        } else {
            Box(
                modifier = Modifier
                    .size(16.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(CyberCardBorder)
            )
        }

        Spacer(modifier = Modifier.width(10.dp))

        Column {
            Text(
                text = title,
                color = if (isActive || isDone) CyberText else CyberTextMuted,
                fontSize = 11.sp,
                fontWeight = if (isActive || isDone) FontWeight.Bold else FontWeight.Normal
            )
            Text(
                text = subtitle,
                color = CyberTextMuted,
                fontSize = 9.sp
            )
        }
    }
}
