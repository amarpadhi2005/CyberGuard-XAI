package com.cyberguard.xai

import com.cyberguard.xai.core.rules.UrlThreatDetector
import com.cyberguard.xai.presentation.components.RiskSeverity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class UrlThreatDetectorTest {

    @Test
    fun testUrlNormalization() {
        val raw = "  HTTP://Example.COM:80/path/test/#section1  "
        val normalized = UrlThreatDetector.normalizeUrl(raw)
        assertEquals("http://example.com/path/test/", normalized)

        val noScheme = "chase.com/login"
        val normNoScheme = UrlThreatDetector.normalizeUrl(noScheme)
        assertEquals("https://chase.com/login", normNoScheme)
    }

    @Test
    fun testHttpsCheck() {
        val httpEval = UrlThreatDetector.evaluate("http://mybank-account.com/login")
        assertFalse(httpEval.isHttps)
        assertTrue(httpEval.reasons.any { it.contains("Unencrypted HTTP") })
        assertTrue(httpEval.riskScore >= 30)

        val httpsEval = UrlThreatDetector.evaluate("https://mybank-account.com/login")
        assertTrue(httpsEval.isHttps)
    }

    @Test
    fun testSuspiciousDomainDetection() {
        val eval = UrlThreatDetector.evaluate("https://fast-cash-reward.top")
        assertTrue(eval.hasSuspiciousTld)
        assertTrue(eval.reasons.any { it.contains("High-abuse top-level domain (.top)") })
        assertTrue(eval.riskScore >= 30)
    }

    @Test
    fun testLookalikeDomainDetection() {
        // Character substitution typosquatting
        val typosquatEval = UrlThreatDetector.evaluate("https://paypa1-security.com/login")
        assertTrue(typosquatEval.hasLookalikeDomain)
        assertEquals("paypal", typosquatEval.lookalikeTarget)
        assertTrue(typosquatEval.riskScore >= 50)

        // Subdomain spoof
        val subdomainSpoof = UrlThreatDetector.evaluate("https://paypal.com.verify-identity.xyz")
        assertTrue(subdomainSpoof.hasLookalikeDomain)
        assertEquals("paypal", subdomainSpoof.lookalikeTarget)
        assertTrue(subdomainSpoof.hasSuspiciousTld)
        assertTrue(subdomainSpoof.riskScore >= 70)
    }

    @Test
    fun testExcessiveSubdomainsDetection() {
        val eval = UrlThreatDetector.evaluate("https://auth.login.verify.account.chase.fakehost.com")
        assertTrue(eval.hasExcessiveSubdomains)
        assertTrue(eval.subdomainCount >= 2)
        assertTrue(eval.reasons.any { it.contains("Excessive subdomain depth") })
    }

    @Test
    fun testSuspiciousPathDetection() {
        val eval = UrlThreatDetector.evaluate("https://legitlookingdomain.org/account-update.php")
        assertTrue(eval.hasSuspiciousPath)
        assertTrue(eval.reasons.any { it.contains("authentication path keywords") })
    }

    @Test
    fun testIpAddressUrlDetection() {
        val eval = UrlThreatDetector.evaluate("http://192.168.1.100/admin/login")
        assertTrue(eval.isIpAddress)
        assertTrue(eval.reasons.any { it.contains("raw IP address") })
        assertTrue(eval.riskScore >= 50)
    }

    @Test
    fun testUrlShorteningDetection() {
        val eval = UrlThreatDetector.evaluate("https://bit.ly/3abc123")
        assertTrue(eval.isShortened)
        assertTrue(eval.reasons.any { it.contains("link shortener") })
    }

    @Test
    fun testKnownThreatLookup() {
        val eval = UrlThreatDetector.evaluate("http://paypa1-verify.top/auth")
        assertTrue(eval.isKnownThreat)
        assertEquals(100, eval.riskScore)
        assertEquals(RiskSeverity.CRITICAL, eval.severity)
        assertTrue(eval.reasons.any { it.contains("active Threat Intelligence blacklist") })
    }

    @Test
    fun testSafeCleanUrl() {
        val eval = UrlThreatDetector.evaluate("https://www.google.com")
        assertTrue(eval.isHttps)
        assertFalse(eval.isIpAddress)
        assertFalse(eval.isShortened)
        assertFalse(eval.hasLookalikeDomain)
        assertFalse(eval.hasSuspiciousPath)
        assertFalse(eval.hasSuspiciousTld)
        assertEquals(0, eval.riskScore)
        assertEquals(RiskSeverity.SAFE, eval.severity)
        assertTrue(eval.recommendation.startsWith("SAFE"))
    }
}
