package com.cyberguard.xai

import com.cyberguard.xai.core.rules.QrThreatDetector
import com.cyberguard.xai.domain.model.QrPayloadType
import com.cyberguard.xai.presentation.components.RiskSeverity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class QrThreatDetectorTest {

    @Test
    fun testPhishingUrlQr() {
        val payload = "http://paypa1-account-security.top/login"
        val eval = QrThreatDetector.evaluate(payload)

        assertTrue(eval.isUrl)
        assertFalse(eval.isPaymentOrDeepLink)
        assertEquals(QrPayloadType.URL, eval.payloadType)
        assertNotNull(eval.urlEvaluation)
        assertTrue(eval.riskScore >= 70)
        assertTrue(eval.severity >= RiskSeverity.HIGH)
        assertTrue(eval.requiresExplicitConsentToOpen)
        assertTrue(eval.warningTitle?.contains("DANGEROUS QR LINK") == true)
        assertTrue(eval.recommendation.contains("NEVER OPEN THIS URL"))
    }

    @Test
    fun testDirectApkDownloadUrlQr() {
        val payload = "https://unverified-app-store.xyz/download/update_cyber.apk"
        val eval = QrThreatDetector.evaluate(payload)

        assertTrue(eval.isUrl)
        assertTrue(eval.reasons.any { it.contains("unsigned Android Package (.apk)") })
        assertTrue(eval.riskScore >= 60)
    }

    @Test
    fun testDeceptiveUpiPaymentQr() {
        val upiUri = "upi://pay?pa=scam-desk@upi&pn=Bank%20KYC%20Support%20Officer&am=5000&cu=INR&tn=Refund%20Validation"
        val eval = QrThreatDetector.evaluate(upiUri)

        assertFalse(eval.isUrl)
        assertTrue(eval.isPaymentOrDeepLink)
        assertEquals(QrPayloadType.PAYMENT_UPI, eval.payloadType)
        assertNotNull(eval.paymentDetails)
        assertEquals("Bank KYC Support Officer", eval.paymentDetails?.payeeName)
        assertEquals("5000", eval.paymentDetails?.amount)
        assertTrue(eval.paymentDetails?.isDeceptivePayee == true)
        assertTrue(eval.riskScore >= 75)
        assertTrue(eval.reasons.any { it.contains("imposter scam") })
        assertTrue(eval.warningTitle?.contains("PAYMENT TRANSFER ALERT") == true)
    }

    @Test
    fun testCryptoWalletQr() {
        val cryptoUri = "bitcoin:1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa?amount=0.5"
        val eval = QrThreatDetector.evaluate(cryptoUri)

        assertFalse(eval.isUrl)
        assertTrue(eval.isPaymentOrDeepLink)
        assertEquals(QrPayloadType.PAYMENT_CRYPTO, eval.payloadType)
        assertNotNull(eval.paymentDetails)
        assertEquals("BITCOIN", eval.paymentDetails?.scheme)
        assertTrue(eval.reasons.any { it.contains("irreversible") })
        assertTrue(eval.warningTitle?.contains("CRYPTOCURRENCY WALLET") == true)
    }

    @Test
    fun testDeepLinkIntentQr() {
        val intentUri = "intent://scan/#Intent;scheme=maliciousapp;package=com.victim.app;end"
        val eval = QrThreatDetector.evaluate(intentUri)

        assertFalse(eval.isUrl)
        assertTrue(eval.isPaymentOrDeepLink)
        assertEquals(QrPayloadType.DEEP_LINK, eval.payloadType)
        assertTrue(eval.riskScore >= 70)
        assertTrue(eval.reasons.any { it.contains("Android Intent URI") })
        assertTrue(eval.warningTitle?.contains("APP INTENT LAUNCH") == true)
    }

    @Test
    fun testUnencryptedWifiQr() {
        val wifiUri = "WIFI:T:nopass;S:FreeHackerHotspot;P:;;;;"
        val eval = QrThreatDetector.evaluate(wifiUri)

        assertFalse(eval.isUrl)
        assertFalse(eval.isPaymentOrDeepLink)
        assertEquals(QrPayloadType.WIFI_CONFIG, eval.payloadType)
        assertTrue(eval.reasons.any { it.contains("Unencrypted open Wi-Fi") })
        assertTrue(eval.riskScore >= 50)
    }

    @Test
    fun testSafeWebUrlQr() {
        val safeUrl = "https://www.google.com"
        val eval = QrThreatDetector.evaluate(safeUrl)

        assertTrue(eval.isUrl)
        assertEquals(0, eval.riskScore)
        assertEquals(RiskSeverity.SAFE, eval.severity)
        assertEquals("VERIFIED WEB LINK", eval.warningTitle)
    }
}
