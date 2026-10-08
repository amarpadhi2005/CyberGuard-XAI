package com.cyberguard.xai

import com.cyberguard.xai.core.rules.AiAssistantEngine
import com.cyberguard.xai.domain.model.AiAttachedContext
import com.cyberguard.xai.domain.model.AiContextType
import com.cyberguard.xai.presentation.components.RiskSeverity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AiAssistantEngineTest {

    @Test
    fun testUrlContextIsThisSafeQuestion() {
        val context = AiAttachedContext(
            type = AiContextType.URL,
            title = "Phishing URL",
            content = "http://paypa1-account-security.top/login"
        )
        val response = AiAssistantEngine.generateResponse("Is this safe?", context)

        assertTrue(response.risk.contains("CRITICAL") || response.risk.contains("HIGH"))
        assertTrue(response.explanation.contains("No, this link is NOT safe"))
        assertTrue(response.evidence.isNotEmpty())
        assertTrue(response.confidence.contains("High"))
        assertTrue(response.recommendedAction.isNotEmpty())
    }

    @Test
    fun testPastedMessageWhyIsThisSuspiciousQuestion() {
        val context = AiAttachedContext(
            type = AiContextType.PASTED_MESSAGE,
            title = "SMS Message",
            content = "URGENT: Your bank account is suspended immediately. Send your 6-digit OTP code to unlock."
        )
        val response = AiAssistantEngine.generateResponse("Why is this suspicious?", context)

        assertTrue(response.evidence.any { it.contains("OTP") || it.contains("passcode") })
        assertTrue(response.evidence.any { it.contains("urgency") })
        assertTrue(response.explanation.contains("Suspicious traits detected"))
        assertTrue(response.severity >= RiskSeverity.HIGH)
    }

    @Test
    fun testQrResultWhatShouldIDoQuestion() {
        val context = AiAttachedContext(
            type = AiContextType.QR_RESULT,
            title = "UPI QR Scan",
            content = "upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation&am=5000"
        )
        val response = AiAssistantEngine.generateResponse("What should I do?", context)

        assertTrue(response.explanation.contains("DO NOT enter your UPI PIN"))
        assertTrue(response.evidence.isNotEmpty())
        assertTrue(response.confidence.contains("High"))
    }

    @Test
    fun testCallRiskHowSeriousQuestion() {
        val context = AiAttachedContext(
            type = AiContextType.CALL_RISK,
            title = "Incoming Vishing Call",
            content = "+1-800-424-9098",
            metadata = mapOf(
                "riskScore" to "85",
                "reasons" to "VoIP spoofing origin;IRS impersonator report;Deepfake voice synth"
            )
        )
        val response = AiAssistantEngine.generateResponse("How serious is this?", context)

        assertTrue(response.risk.contains("CRITICAL"))
        assertTrue(response.explanation.contains("Severity is CRITICAL"))
        assertTrue(response.evidence.any { it.contains("IRS impersonator") })
    }

    @Test
    fun testHowCanIVerifyQuestion() {
        val context = AiAttachedContext(
            type = AiContextType.URL,
            title = "Target URL",
            content = "https://suspicious-reward-portal.xyz/claim"
        )
        val response = AiAssistantEngine.generateResponse("How can I verify this?", context)

        assertTrue(response.explanation.contains("WHOIS") || response.explanation.contains("official website"))
        assertTrue(response.recommendedAction.isNotEmpty())
    }

    @Test
    fun testNeverClaimCertaintyOnInsufficientEvidence() {
        val context = AiAttachedContext(
            type = AiContextType.PASTED_MESSAGE,
            title = "Brief Message",
            content = "Hello there"
        )
        val response = AiAssistantEngine.generateResponse("Is this safe?", context)

        assertEquals("UNCERTAIN / INSUFFICIENT EVIDENCE", response.risk)
        assertFalse(response.isCertaintyClaimed)
        assertTrue(response.confidence.contains("Low"))
        assertTrue(response.explanation.contains("insufficient textual context"))
    }
}
