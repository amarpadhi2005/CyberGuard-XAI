package com.cyberguard.xai

import android.graphics.RectF
import com.cyberguard.xai.core.deepfake.DeepfakeDetectionModel
import com.cyberguard.xai.core.deepfake.DeepfakeMediaType
import com.cyberguard.xai.core.deepfake.DeepfakeModelInput
import com.cyberguard.xai.core.deepfake.DeepfakeModelOutput
import com.cyberguard.xai.core.deepfake.DetectedFace
import com.cyberguard.xai.core.deepfake.ExtractedFrame
import com.cyberguard.xai.core.deepfake.PrototypeHeuristicDeepfakeModel
import com.cyberguard.xai.presentation.components.RiskSeverity
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class DeepfakePipelineTest {

    @Test
    fun testPrototypeModel_emptyFace_returnsInconclusiveExplanation() = runBlocking {
        val model = PrototypeHeuristicDeepfakeModel()

        val input = DeepfakeModelInput(
            mediaType = DeepfakeMediaType.IMAGE,
            fileName = "scenery_no_face.jpg",
            fileSize = 102400L,
            durationMs = null,
            extractedFrames = listOf(
                ExtractedFrame(0, 0L, null, 640, 480)
            ),
            detectedFaces = emptyList(),
            totalFramesAnalyzed = 1
        )

        val output = model.infer(input)

        assertTrue(output.isPrototypeAnalysis)
        assertFalse(output.isSynthetic)
        assertTrue(output.confidence < 0.50f) // Honest low confidence when no ROI is present
        assertTrue(output.explanation.contains("No human faces detected"))
        assertEquals("CyberGuard Pluggable Prototype Forensics (1.0.0-prototype)", output.modelIdentifier)
    }

    @Test
    fun testPrototypeModel_audioCloning_detectsAcousticAnomalies() = runBlocking {
        val model = PrototypeHeuristicDeepfakeModel()

        val input = DeepfakeModelInput(
            mediaType = DeepfakeMediaType.AUDIO,
            fileName = "urgent_wire_transfer_voicemail.wav",
            fileSize = 95000L,
            durationMs = 12000L,
            extractedFrames = emptyList(),
            detectedFaces = emptyList(),
            totalFramesAnalyzed = 0
        )

        val output = model.infer(input)

        assertTrue(output.isPrototypeAnalysis)
        assertTrue(output.isSynthetic)
        assertTrue(output.riskScore >= 50)
        assertTrue(output.confidence in 0.5f..0.99f) // Honest un-fabricated confidence range
        assertTrue(output.detectedAnomalies.isNotEmpty())
        assertTrue(output.explanation.contains("Prototype spectral analysis detected neural vocoder"))
    }

    @Test
    fun testPluggableInterface_allowsCustomModelReplacement() = runBlocking {
        // Demonstrate clean pluggability: A production TFLite/ONNX model can replace the prototype
        val customModel = object : DeepfakeDetectionModel {
            override val modelName: String = "TestPluggableModel"
            override val modelVersion: String = "2.0.0"
            override val isPrototypeModel: Boolean = false

            override suspend fun infer(input: DeepfakeModelInput): DeepfakeModelOutput {
                return DeepfakeModelOutput(
                    isSynthetic = true,
                    syntheticLikelihood = 99.0f,
                    confidence = 0.95f,
                    riskScore = 95,
                    severity = RiskSeverity.CRITICAL,
                    detectedAnomalies = emptyList(),
                    explanation = "Inferred by custom pluggable neural model",
                    countermeasureAdvisory = "Custom advisory",
                    modelIdentifier = "$modelName ($modelVersion)",
                    isPrototypeAnalysis = false
                )
            }
        }

        val input = DeepfakeModelInput(
            mediaType = DeepfakeMediaType.IMAGE,
            fileName = "test.png",
            fileSize = 5000L,
            durationMs = null,
            extractedFrames = emptyList(),
            detectedFaces = emptyList(),
            totalFramesAnalyzed = 0
        )

        val output = customModel.infer(input)

        assertEquals("TestPluggableModel (2.0.0)", output.modelIdentifier)
        assertFalse(output.isPrototypeAnalysis)
        assertEquals(95, output.riskScore)
    }
}
