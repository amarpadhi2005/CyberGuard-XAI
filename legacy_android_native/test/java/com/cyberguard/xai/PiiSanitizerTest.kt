package com.cyberguard.xai

import com.cyberguard.xai.core.security.PiiSanitizer
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PiiSanitizerTest {

    @Test
    fun testOtpMasking() {
        val raw = "Your verification code is 849201 for banking login"
        val sanitized = PiiSanitizer.sanitizeText(raw)
        assertFalse(sanitized.contains("849201"))
        assertTrue(sanitized.contains("[REDACTED_OTP]"))
    }

    @Test
    fun testCardMasking() {
        val raw = "Payment charged to Visa 4111-2222-3333-4444 successfully"
        val sanitized = PiiSanitizer.sanitizeText(raw)
        assertFalse(sanitized.contains("4111-2222-3333-4444"))
        assertTrue(sanitized.contains("[REDACTED_CARD]"))
    }

    @Test
    fun testAccountMasking() {
        val raw = "Notice regarding a/c 9876543210: please confirm transaction"
        val sanitized = PiiSanitizer.sanitizeText(raw)
        assertFalse(sanitized.contains("9876543210"))
        assertTrue(sanitized.contains("[REDACTED_ACCOUNT]"))
    }

    @Test
    fun testLengthTruncation() {
        val longString = "A".repeat(400)
        val sanitized = PiiSanitizer.sanitizeText(longString, maxLength = 100)
        assertTrue(sanitized.length <= 104) // 100 chars + "..."
        assertTrue(sanitized.endsWith("..."))
    }
}
