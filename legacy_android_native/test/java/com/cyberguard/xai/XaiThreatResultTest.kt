package com.cyberguard.xai

import com.cyberguard.xai.core.rules.QrThreatDetector
import com.cyberguard.xai.core.rules.UrlThreatDetector
import com.cyberguard.xai.core.rules.XaiExplainerFactory
import com.cyberguard.xai.presentation.components.RiskSeverity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class XaiThreatResultTest {

    @Test
    fun testUrlThreatReturnsAllRequiredFields() {
        val urlEval = UrlThreatDetector.evaluate("http://paypa1-account-security.top/login")
        val xai = XaiExplainerFactory.fromUrlEvaluation(urlEval)

        // 1. riskScore
        assertTrue(xai.riskScore in 0..100)
        assertTrue(xai.riskScore >= 70)

        // 2. severity
        assertTrue(xai.severity >= RiskSeverity.HIGH)

        // 3. decision
        assertEquals("BLOCK_THREAT", xai.decision)

        // 4. evidence[]
        assertTrue(xai.evidence.isNotEmpty())
        assertTrue(xai.evidence.any { it.contains("paypal") || it.contains("spoofing") })

        // 5. signals[]
        assertTrue(xai.signals.isNotEmpty())
        val typosquatSignal = xai.signals.find { it.name.contains("Typosquatting") }
        assertNotNull(typosquatSignal)
        assertEquals(45, typosquatSignal?.scoreImpact)
        assertEquals("Domain Governance", typosquatSignal?.category)
        assertFalse(typosquatSignal?.isPositive ?: true)

        // 6. confidence
        assertNotNull(xai.confidence)
        assertTrue(xai.confidence.contains("%"))

        // 7. recommendedAction
        assertNotNull(xai.recommendedAction)
        assertTrue(xai.recommendedAction.isNotEmpty())
    }

    @Test
    fun testCleanSafeUrlReturnsAllowSafeDecision() {
        val urlEval = UrlThreatDetector.evaluate("https://www.google.com")
        val xai = XaiExplainerFactory.fromUrlEvaluation(urlEval)

        assertEquals(0, xai.riskScore)
        assertEquals(RiskSeverity.SAFE, xai.severity)
        assertEquals("ALLOW_SAFE", xai.decision)
        assertTrue(xai.signals.any { it.isPositive })
        assertTrue(xai.evidence.any { it.contains("Clean") || it.contains("HTTPS") })
    }

    @Test
    fun testQrScamReturnsSignalsAndEvidence() {
        val qrEval = QrThreatDetector.evaluate("upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation&am=5000")
        val xai = XaiExplainerFactory.fromQrEvaluation(qrEval)

        assertTrue(xai.riskScore >= 70)
        assertEquals("BLOCK_THREAT", xai.decision)
        assertTrue(xai.signals.any { it.category == "Identity & Impersonation" })
        assertTrue(xai.signals.any { it.name.contains("Imposter") })
        assertTrue(xai.evidence.any { it.contains("impersonating") || it.contains("authority") })
        assertTrue(xai.recommendedAction.contains("UPI PIN"))
    }

    @Test
    fun testNeverExposePrivateModelChainOfThought() {
        val urlEval = UrlThreatDetector.evaluate("http://paypa1-account-security.top/login")
        val xai = XaiExplainerFactory.fromUrlEvaluation(urlEval)

        // Verify evidence and signals only contain user-facing observable facts
        val combinedText = (xai.evidence + xai.signals.map { it.description } + listOf(xai.recommendedAction)).joinToString(" ")
        assertFalse(combinedText.contains("system prompt", ignoreCase = true))
        assertFalse(combinedText.contains("<thought>", ignoreCase = true))
        assertFalse(combinedText.contains("chain of thought", ignoreCase = true))
        assertFalse(combinedText.contains("hidden reasoning", ignoreCase = true))
    }
}
