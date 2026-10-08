package com.cyberguard.xai.core.rules

import com.cyberguard.xai.presentation.components.RiskSeverity
import java.util.regex.Pattern

data class NotificationRuleVerdict(
    val isThreat: Boolean,
    val riskScore: Int,
    val severity: RiskSeverity,
    val primaryThreatType: String,
    val detectedCategories: List<String>,
    val extractedUrls: List<String>,
    val xaiExplanation: String,
    val suggestedAction: String,
    val requiresBackendEscalation: Boolean
)

object NotificationRuleEngine {

    // 1. Suspicious URL Pattern & High-Abuse TLDs
    private val URL_REGEX = Pattern.compile(
        """(?i)\b(?:https?://|www\.)[a-z0-9\-._~:/?#\[\]@!$&'()*+,;=]+""",
        Pattern.CASE_INSENSITIVE
    )
    private val SUSPICIOUS_TLDS = listOf(
        ".top", ".xyz", ".free", ".click", ".link", ".buzz", ".cam", ".work", ".cfd", ".monster"
    )
    private val IP_HOST_REGEX = Pattern.compile("""https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}""")

    // 2. Urgent Language
    private val URGENCY_REGEX = Pattern.compile(
        """(?i)\b(?:immediately|urgent|within\s+\d+\s*(?:hours?|mins?)|locked|suspended|arrest\s*warrant|final\s*notice|legal\s*action|deactivated|emergency)\b"""
    )

    // 3. Payment Requests
    private val PAYMENT_REGEX = Pattern.compile(
        """(?i)\b(?:wire\s*transfer|send\s*\$|gift\s*card|crypto|bitcoin|usdt|pay\s*now|processing\s*fee|transfer\s*funds|western\s*union)\b"""
    )

    // 4. OTP Requests
    private val OTP_REQUEST_REGEX = Pattern.compile(
        """(?i)\b(?:share\s*(?:your)?\s*otp|send\s*(?:the)?\s*(?:\d+-digit)?\s*code|forward\s*(?:sms)?\s*code|verify\s*otp|tell\s*(?:me)?\s*code)\b"""
    )

    // 5. Impersonation
    private val IMPERSONATION_REGEX = Pattern.compile(
        """(?i)\b(?:irs|paypal|bank\s*of\s*america|chase|wells\s*fargo|federal\s*reserve|customs|whatsapp\s*support|apple\s*security|amazon\s*fraud|netflix\s*billing)\b"""
    )

    // 6. Reward Scams
    private val REWARD_REGEX = Pattern.compile(
        """(?i)\b(?:you\s*won|congratulations|lottery|claim\s*(?:your)?\s*prize|free\s*iphone|cash\s*reward|selected\s*winner|lucky\s*draw|unclaimed\s*bonus)\b"""
    )

    // 7. Fake KYC
    private val FAKE_KYC_REGEX = Pattern.compile(
        """(?i)\b(?:update\s*kyc|kyc\s*(?:verification|expired|pending)|pan\s*card\s*blocked|aadhaar\s*(?:suspended|update)|complete\s*kyc)\b"""
    )

    // 8. Suspicious Financial Requests
    private val SUSPICIOUS_FINANCIAL_REGEX = Pattern.compile(
        """(?i)\b(?:unauthorized\s*transaction|refund\s*approved|investment\s*guarantee|double\s*(?:your)?\s*money|tax\s*refund\s*pending|account\s*debited\s*\$)\b"""
    )

    fun evaluate(title: String?, text: String?): NotificationRuleVerdict {
        val combinedText = "${title.orEmpty()} ${text.orEmpty()}".trim()
        if (combinedText.isBlank()) {
            return createSafeVerdict()
        }

        var score = 0
        val detectedCategories = mutableListOf<String>()
        val indicators = mutableListOf<String>()

        // 1. URL Analysis
        val extractedUrls = extractUrls(combinedText)
        var urlThreatFound = false
        for (url in extractedUrls) {
            val lowerUrl = url.lowercase()
            val isSuspiciousTld = SUSPICIOUS_TLDS.any { lowerUrl.contains(it) }
            val isIpAddress = IP_HOST_REGEX.matcher(lowerUrl).find()
            val isHttp = lowerUrl.startsWith("http://")

            if (isSuspiciousTld || isIpAddress || isHttp) {
                urlThreatFound = true
                score += 35
                detectedCategories.add("SUSPICIOUS_URL")
                indicators.add("Detected suspicious hyperlink: $url (High-risk TLD or unencrypted protocol)")
                break
            } else {
                // Generic URL in notification
                score += 15
                indicators.add("External hyperlink present in message payload")
            }
        }

        // 2. Urgent Language
        if (URGENCY_REGEX.matcher(combinedText).find()) {
            score += 20
            detectedCategories.add("COERCIVE_URGENCY")
            indicators.add("Coercive high-urgency language attempting psychological pressure")
        }

        // 3. Payment Requests
        if (PAYMENT_REGEX.matcher(combinedText).find()) {
            score += 25
            detectedCategories.add("UNSOLICITED_PAYMENT")
            indicators.add("Demand for irreversible payment (wire, gift card, or cryptocurrency)")
        }

        // 4. OTP Requests
        if (OTP_REQUEST_REGEX.matcher(combinedText).find()) {
            score += 40
            detectedCategories.add("OTP_THEFT")
            indicators.add("Direct attempt to harvest authentication code or one-time passcode")
        }

        // 5. Impersonation
        if (IMPERSONATION_REGEX.matcher(combinedText).find()) {
            score += 25
            detectedCategories.add("BRAND_IMPERSONATION")
            indicators.add("Mentions trusted institution/bank/authority to induce false credibility")
        }

        // 6. Reward Scams
        if (REWARD_REGEX.matcher(combinedText).find()) {
            score += 35
            detectedCategories.add("REWARD_SCAM")
            indicators.add("Unrealistic prize, lottery, or windfall reward lure")
        }

        // 7. Fake KYC
        if (FAKE_KYC_REGEX.matcher(combinedText).find()) {
            score += 35
            detectedCategories.add("FAKE_KYC")
            indicators.add("Urgent claim that KYC/identity documentation has expired or is blocked")
        }

        // 8. Suspicious Financial Requests
        if (SUSPICIOUS_FINANCIAL_REGEX.matcher(combinedText).find()) {
            score += 25
            detectedCategories.add("FINANCIAL_FRAUD")
            indicators.add("Fake transaction debit notification or unauthorized refund lure")
        }

        val finalScore = score.coerceIn(0, 100)
        val isThreat = finalScore >= 50

        val severity = when {
            finalScore >= 85 -> RiskSeverity.CRITICAL
            finalScore >= 70 -> RiskSeverity.HIGH
            finalScore >= 50 -> RiskSeverity.MEDIUM
            finalScore >= 30 -> RiskSeverity.LOW
            else -> RiskSeverity.SAFE
        }

        val primaryType = determinePrimaryThreatType(detectedCategories)

        val explanation = if (indicators.isNotEmpty()) {
            indicators.joinToString(separator = ". ") + "."
        } else {
            "Message contains normal communication patterns."
        }

        val action = when {
            finalScore >= 70 -> "Do NOT tap any links or share codes. Dismiss and report sender immediately."
            finalScore >= 50 -> "Exercise high caution. Verify directly with official organization via known app."
            else -> "No immediate threat detected."
        }

        return NotificationRuleVerdict(
            isThreat = isThreat,
            riskScore = finalScore,
            severity = severity,
            primaryThreatType = primaryType,
            detectedCategories = detectedCategories,
            extractedUrls = extractedUrls,
            xaiExplanation = explanation,
            suggestedAction = action,
            requiresBackendEscalation = isThreat || finalScore >= 35
        )
    }

    private fun extractUrls(text: String): List<String> {
        val urls = mutableListOf<String>()
        val matcher = URL_REGEX.matcher(text)
        while (matcher.find()) {
            urls.add(matcher.group())
        }
        return urls
    }

    private fun determinePrimaryThreatType(categories: List<String>): String {
        return when {
            categories.contains("OTP_THEFT") -> "OTP_THEFT"
            categories.contains("FAKE_KYC") -> "FAKE_KYC"
            categories.contains("SUSPICIOUS_URL") -> "SMISHING_URL"
            categories.contains("REWARD_SCAM") -> "REWARD_SCAM"
            categories.contains("BRAND_IMPERSONATION") -> "IMPERSONATION"
            categories.contains("UNSOLICITED_PAYMENT") -> "PAYMENT_FRAUD"
            categories.contains("FINANCIAL_FRAUD") -> "FINANCIAL_SCAM"
            categories.contains("COERCIVE_URGENCY") -> "SOCIAL_ENGINEERING"
            else -> "SUSPICIOUS_NOTIFICATION"
        }
    }

    private fun createSafeVerdict() = NotificationRuleVerdict(
        isThreat = false,
        riskScore = 0,
        severity = RiskSeverity.SAFE,
        primaryThreatType = "BENIGN",
        detectedCategories = emptyList(),
        extractedUrls = emptyList(),
        xaiExplanation = "Safe message content.",
        suggestedAction = "Normal communication.",
        requiresBackendEscalation = false
    )
}
