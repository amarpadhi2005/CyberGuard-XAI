package com.cyberguard.xai.core.security

import java.util.regex.Pattern

object PiiSanitizer {

    // Matches 4 to 8 digit verification codes near security keywords
    private val OTP_PATTERN = Pattern.compile(
        """(?i)(?:code|otp|pin|verification|passcode|secret)[\s:=-]+(\d{4,8})"""
    )
    private val STANDALONE_CODE_PATTERN = Pattern.compile("""\b\d{6,8}\b""")

    // Matches credit card numbers (13-19 digits, with or without spaces/dashes)
    private val CARD_PATTERN = Pattern.compile(
        """\b(?:\d{4}[- ]?){3}\d{4}\b|\b\d{15,16}\b"""
    )

    // Matches bank account / SSN / Aadhaar numbers (9-12 digits)
    private val ACCOUNT_PATTERN = Pattern.compile(
        """(?i)(?:a/c|account|ssn|aadhaar|pan)[\s:=-]+([a-z0-9\s-]{6,16})"""
    )

    fun sanitizeText(text: String, maxLength: Int = 200): String {
        if (text.isBlank()) return ""

        var sanitized = text

        // 1. Redact OTPs
        val otpMatcher = OTP_PATTERN.matcher(sanitized)
        if (otpMatcher.find()) {
            sanitized = otpMatcher.replaceAll("code: [REDACTED_OTP]")
        } else {
            // Also redact standalone 6-8 digit tokens
            sanitized = STANDALONE_CODE_PATTERN.matcher(sanitized).replaceAll("[REDACTED_OTP]")
        }

        // 2. Redact Card numbers
        sanitized = CARD_PATTERN.matcher(sanitized).replaceAll("[REDACTED_CARD]")

        // 3. Redact Bank accounts / SSNs
        sanitized = ACCOUNT_PATTERN.matcher(sanitized).replaceAll("account: [REDACTED_ACCOUNT]")

        // 4. Truncate to maximum necessary length to respect user privacy
        return if (sanitized.length > maxLength) {
            sanitized.take(maxLength) + "..."
        } else {
            sanitized
        }
    }
}
