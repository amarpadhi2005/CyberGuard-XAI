package com.cyberguard.xai

import com.cyberguard.xai.core.rules.NotificationRuleEngine
import com.cyberguard.xai.presentation.components.RiskSeverity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NotificationRuleEngineTest {

    @Test
    fun testSuspiciousUrlDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Bank Notice",
            text = "Verify your account at http://secure-portal.top immediately"
        )
        assertTrue(verdict.isThreat)
        assertTrue(verdict.detectedCategories.contains("SUSPICIOUS_URL"))
        assertTrue(verdict.detectedCategories.contains("COERCIVE_URGENCY"))
        assertEquals("SMISHING_URL", verdict.primaryThreatType)
        assertTrue(verdict.riskScore >= 50)
    }

    @Test
    fun testUrgentLanguageDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Security Alert",
            text = "Your account has been locked. Final notice: legal action within 24 hours"
        )
        assertTrue(verdict.detectedCategories.contains("COERCIVE_URGENCY"))
        assertTrue(verdict.riskScore > 0)
    }

    @Test
    fun testPaymentRequestDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Emergency Help",
            text = "Please wire transfer $500 via gift card or crypto to resolve processing fee"
        )
        assertTrue(verdict.detectedCategories.contains("UNSOLICITED_PAYMENT"))
        assertTrue(verdict.riskScore > 0)
    }

    @Test
    fun testOtpRequestDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Customer Care",
            text = "Hello, please share your 6-digit OTP verification code with support to prevent deactivation"
        )
        assertTrue(verdict.isThreat)
        assertTrue(verdict.detectedCategories.contains("OTP_THEFT"))
        assertEquals("OTP_THEFT", verdict.primaryThreatType)
        assertEquals(RiskSeverity.HIGH, verdict.severity)
    }

    @Test
    fun testImpersonationDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "IRS Warning",
            text = "IRS department has flagged your tax return for immediate audit"
        )
        assertTrue(verdict.detectedCategories.contains("BRAND_IMPERSONATION"))
        assertTrue(verdict.riskScore > 0)
    }

    @Test
    fun testRewardScamDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Lucky Winner",
            text = "Congratulations! You won $10,000 cash reward. Claim your prize at http://free-reward.xyz"
        )
        assertTrue(verdict.isThreat)
        assertTrue(verdict.detectedCategories.contains("REWARD_SCAM"))
        assertTrue(verdict.detectedCategories.contains("SUSPICIOUS_URL"))
        assertTrue(verdict.riskScore >= 70)
    }

    @Test
    fun testFakeKycDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Bank Service",
            text = "Your PAN card is blocked. Complete KYC verification immediately"
        )
        assertTrue(verdict.isThreat)
        assertTrue(verdict.detectedCategories.contains("FAKE_KYC"))
        assertTrue(verdict.riskScore >= 50)
    }

    @Test
    fun testSuspiciousFinancialRequestDetection() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Alert",
            text = "Unauthorized transaction of $900 detected. Refund approved, claim here http://refund.top"
        )
        assertTrue(verdict.isThreat)
        assertTrue(verdict.detectedCategories.contains("FINANCIAL_FRAUD"))
        assertTrue(verdict.detectedCategories.contains("SUSPICIOUS_URL"))
    }

    @Test
    fun testBenignNotification() {
        val verdict = NotificationRuleEngine.evaluate(
            title = "Mom",
            text = "Hey honey, dinner is ready at 7pm tonight. Love you!"
        )
        assertFalse(verdict.isThreat)
        assertEquals(0, verdict.riskScore)
        assertEquals(RiskSeverity.SAFE, verdict.severity)
        assertTrue(verdict.detectedCategories.isEmpty())
    }
}
