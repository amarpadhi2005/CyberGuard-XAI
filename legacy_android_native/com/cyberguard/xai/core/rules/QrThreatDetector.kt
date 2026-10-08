package com.cyberguard.xai.core.rules

import android.net.Uri
import com.cyberguard.xai.domain.model.QrPayloadType
import com.cyberguard.xai.domain.model.QrPaymentDetails
import com.cyberguard.xai.domain.model.QrThreatEvaluation
import com.cyberguard.xai.presentation.components.RiskSeverity
import java.util.Locale
import java.util.regex.Pattern

object QrThreatDetector {

    private val URL_PREFIX_PATTERN = Pattern.compile("^(?i)(https?|ftp)://.+")
    private val DOMAIN_LIKE_PATTERN = Pattern.compile("^(?i)[a-zA-Z0-9-]+\\.[a-zA-Z]{2,}(/.*)?$")
    
    // Deceptive keywords in payment payee name or transaction memo
    private val DECEPTIVE_PAYEE_KEYWORDS = listOf(
        "support", "refund", "kyc", "prize", "cashback", "lottery",
        "security", "customercare", "verification", "claim", "reward",
        "officer", "helpdesk", "telecom", "bank"
    )

    fun evaluate(rawPayload: String): QrThreatEvaluation {
        val trimmed = rawPayload.trim()
        if (trimmed.isEmpty()) {
            return createEmptyEvaluation()
        }

        // 1. Check if it's a URL
        if (isUrlPayload(trimmed)) {
            val urlEval = UrlThreatDetector.evaluate(trimmed)
            val reasons = mutableListOf<String>()
            reasons.addAll(urlEval.reasons)

            // Additional QR-specific URL vectors (e.g. direct APK download)
            val isApkDownload = trimmed.endsWith(".apk", ignoreCase = true) || trimmed.contains(".apk?")
            var extraScore = 0

            if (isApkDownload) {
                extraScore += 30
                reasons.add("QR code initiates direct download of unsigned Android Package (.apk)")
            }

            val finalScore = (urlEval.riskScore + extraScore).coerceIn(0, 100)
            val finalSeverity = when {
                finalScore >= 85 -> RiskSeverity.CRITICAL
                finalScore >= 70 -> RiskSeverity.HIGH
                finalScore >= 50 -> RiskSeverity.MEDIUM
                finalScore >= 25 -> RiskSeverity.LOW
                else -> RiskSeverity.SAFE
            }

            val isThreat = finalScore >= 50

            val warningTitle = if (isThreat) "DANGEROUS QR LINK BLOCKED" else "VERIFIED WEB LINK"
            val warningMessage = if (isThreat) {
                "CyberGuard prevented automatic navigation. This QR link was flagged for malicious or phishing indicators. Never open unverified links."
            } else {
                "Standard web hyperlink decoded. Confirm domain authenticity before proceeding."
            }

            val recommendation = if (isThreat) {
                "NEVER OPEN THIS URL. Discard this QR code and do not enter any credentials or download files."
            } else {
                "Review destination domain (${urlEval.domain}) before opening in your browser."
            }

            return QrThreatEvaluation(
                rawPayload = trimmed,
                payloadType = QrPayloadType.URL,
                isUrl = true,
                isPaymentOrDeepLink = false,
                urlEvaluation = urlEval,
                paymentDetails = null,
                riskScore = finalScore,
                severity = finalSeverity,
                reasons = reasons,
                recommendation = recommendation,
                warningTitle = warningTitle,
                warningMessage = warningMessage,
                requiresExplicitConsentToOpen = true
            )
        }

        // 2. Check for UPI Payment Scheme
        if (trimmed.startsWith("upi://pay", ignoreCase = true)) {
            return evaluateUpiPayload(trimmed)
        }

        // 3. Check for Cryptocurrency Payment Schemes
        if (isCryptoPayload(trimmed)) {
            return evaluateCryptoPayload(trimmed)
        }

        // 4. Check for Digital Wallet App Schemes
        if (isWalletPayload(trimmed)) {
            return evaluateWalletPayload(trimmed)
        }

        // 5. Check for Generic App Deep-Link / Intent Schemes
        if (isDeepLinkPayload(trimmed)) {
            return evaluateDeepLinkPayload(trimmed)
        }

        // 6. Check for Wi-Fi Configuration QR
        if (trimmed.startsWith("WIFI:", ignoreCase = true)) {
            return evaluateWifiPayload(trimmed)
        }

        // 7. Plain text or other payload
        return evaluatePlainTextPayload(trimmed)
    }

    private fun isUrlPayload(payload: String): Boolean {
        if (URL_PREFIX_PATTERN.matcher(payload).matches()) return true
        if (DOMAIN_LIKE_PATTERN.matcher(payload).matches() && !payload.contains("://")) return true
        return false
    }

    private fun isCryptoPayload(payload: String): Boolean {
        val lower = payload.lowercase(Locale.ROOT)
        return lower.startsWith("bitcoin:") ||
                lower.startsWith("ethereum:") ||
                lower.startsWith("solana:") ||
                lower.startsWith("bitcoincash:") ||
                lower.startsWith("litecoin:") ||
                lower.startsWith("usdt:")
    }

    private fun isWalletPayload(payload: String): Boolean {
        val lower = payload.lowercase(Locale.ROOT)
        return lower.startsWith("paypal://") ||
                lower.startsWith("venmo://") ||
                lower.startsWith("cashme://") ||
                lower.startsWith("gpay://") ||
                lower.startsWith("phonepe://") ||
                lower.startsWith("paytm://")
    }

    private fun isDeepLinkPayload(payload: String): Boolean {
        val lower = payload.lowercase(Locale.ROOT)
        return lower.startsWith("intent://") ||
                lower.startsWith("market://") ||
                lower.startsWith("package:") ||
                lower.startsWith("app://") ||
                lower.startsWith("tg://") ||
                lower.startsWith("whatsapp://") ||
                (payload.contains("://") && !payload.startsWith("http://", ignoreCase = true) && !payload.startsWith("https://", ignoreCase = true))
    }

    private fun evaluateUpiPayload(rawUri: String): QrThreatEvaluation {
        var score = 45
        val reasons = mutableListOf<String>()

        var payeeAddress: String? = null
        var payeeName: String? = null
        var amount: String? = null
        var currency: String? = "INR"
        var note: String? = null
        var isDeceptive = false

        try {
            val uri = Uri.parse(rawUri)
            payeeAddress = uri.getQueryParameter("pa")
            payeeName = uri.getQueryParameter("pn")
            amount = uri.getQueryParameter("am")
            currency = uri.getQueryParameter("cu") ?: "INR"
            note = uri.getQueryParameter("tn")
        } catch (_: Exception) {
            // Raw string parsing fallback
        }

        reasons.add("UPI payment request decoded; will prompt your banking app to authorize money transfer")

        if (!payeeName.isNullOrBlank()) {
            val lowerPn = payeeName.lowercase(Locale.ROOT)
            if (DECEPTIVE_PAYEE_KEYWORDS.any { lowerPn.contains(it) }) {
                isDeceptive = true
                score += 35
                reasons.add("Payee name '$payeeName' mimics official support or verification departments (common imposter scam)")
            }
        }

        if (!amount.isNullOrBlank()) {
            try {
                val amtVal = amount.toDouble()
                if (amtVal > 0) {
                    score += 20
                    reasons.add("Auto-filled debit transfer amount: $currency $amount (funds will be deducted upon PIN entry)")
                }
            } catch (_: Exception) {}
        } else {
            reasons.add("Open-amount transfer target: user input amount requested")
        }

        val finalScore = score.coerceIn(0, 100)
        val severity = when {
            finalScore >= 80 -> RiskSeverity.CRITICAL
            finalScore >= 65 -> RiskSeverity.HIGH
            else -> RiskSeverity.MEDIUM
        }

        val details = QrPaymentDetails(
            scheme = "UPI",
            payeeAddress = payeeAddress,
            payeeName = payeeName,
            amount = amount,
            currency = currency,
            transactionNote = note,
            isDeceptivePayee = isDeceptive
        )

        return QrThreatEvaluation(
            rawPayload = rawUri,
            payloadType = QrPayloadType.PAYMENT_UPI,
            isUrl = false,
            isPaymentOrDeepLink = true,
            urlEvaluation = null,
            paymentDetails = details,
            riskScore = finalScore,
            severity = severity,
            reasons = reasons,
            recommendation = "WARNING: Verify payee details (${payeeName ?: payeeAddress ?: "Unknown"}) thoroughly. Scammers use pre-filled UPI QRs to trick victims into entering UPI PINs to receive money.",
            warningTitle = "PAYMENT TRANSFER ALERT (UPI)",
            warningMessage = "Scanning this QR code will initiate a financial transaction to '${payeeName ?: payeeAddress}'. Never enter your UPI PIN to receive money.",
            requiresExplicitConsentToOpen = true
        )
    }

    private fun evaluateCryptoPayload(rawUri: String): QrThreatEvaluation {
        val scheme = rawUri.substringBefore(":").uppercase(Locale.ROOT)
        val address = rawUri.substringAfter(":").substringBefore("?")
        val reasons = listOf(
            "Cryptocurrency wallet address targeting $scheme blockchain",
            "Transactions on public blockchains are permanent and irreversible",
            "Frequent target for clipboard-swapping and crypto-drainer malware"
        )

        val details = QrPaymentDetails(
            scheme = scheme,
            payeeAddress = address
        )

        return QrThreatEvaluation(
            rawPayload = rawUri,
            payloadType = QrPayloadType.PAYMENT_CRYPTO,
            isUrl = false,
            isPaymentOrDeepLink = true,
            urlEvaluation = null,
            paymentDetails = details,
            riskScore = 55,
            severity = RiskSeverity.MEDIUM,
            reasons = reasons,
            recommendation = "Exercise extreme caution. Verify the destination wallet address character-by-character before signing.",
            warningTitle = "CRYPTOCURRENCY WALLET DETECTED",
            warningMessage = "Transferring assets to this address cannot be refunded, reversed, or charged back by any bank.",
            requiresExplicitConsentToOpen = true
        )
    }

    private fun evaluateWalletPayload(rawUri: String): QrThreatEvaluation {
        val scheme = rawUri.substringBefore("://")
        return QrThreatEvaluation(
            rawPayload = rawUri,
            payloadType = QrPayloadType.PAYMENT_WALLET,
            isUrl = false,
            isPaymentOrDeepLink = true,
            urlEvaluation = null,
            paymentDetails = QrPaymentDetails(scheme = scheme),
            riskScore = 50,
            severity = RiskSeverity.MEDIUM,
            reasons = listOf(
                "Custom wallet scheme ($scheme) attempting to invoke third-party payment client",
                "Deep-link could initiate payment approval or account link flow"
            ),
            recommendation = "Do not authorize unfamiliar peer-to-peer money transfers.",
            warningTitle = "FINANCIAL APP LAUNCH WARNING",
            warningMessage = "This QR requests to launch payment app '$scheme'. Ensure you initiated this transaction.",
            requiresExplicitConsentToOpen = true
        )
    }

    private fun evaluateDeepLinkPayload(rawUri: String): QrThreatEvaluation {
        val scheme = rawUri.substringBefore("://", rawUri.substringBefore(":"))
        val isIntent = rawUri.startsWith("intent://", ignoreCase = true)
        val score = if (isIntent) 75 else 55
        val severity = if (isIntent) RiskSeverity.HIGH else RiskSeverity.MEDIUM

        val reasons = mutableListOf(
            "Custom application deep-link scheme: '$scheme'",
            "Triggers explicit or implicit Android intent launch on device"
        )
        if (isIntent) {
            reasons.add("Full Android Intent URI detected; can expose vulnerable unexported components or trigger silent APK install")
        }

        return QrThreatEvaluation(
            rawPayload = rawUri,
            payloadType = QrPayloadType.DEEP_LINK,
            isUrl = false,
            isPaymentOrDeepLink = true,
            urlEvaluation = null,
            paymentDetails = null,
            riskScore = score,
            severity = severity,
            reasons = reasons,
            recommendation = "Do not allow unknown deep-links to launch external application processes.",
            warningTitle = "APP INTENT LAUNCH ATTEMPT",
            warningMessage = "This QR code attempts to launch an application deep-link ($scheme). Unauthorized intents may bypass browser sandboxes.",
            requiresExplicitConsentToOpen = true
        )
    }

    private fun evaluateWifiPayload(rawUri: String): QrThreatEvaluation {
        val isNoPass = rawUri.contains(";T:nopass;", ignoreCase = true) || rawUri.contains(";T:none;", ignoreCase = true)
        val score = if (isNoPass) 65 else 20
        val severity = if (isNoPass) RiskSeverity.MEDIUM else RiskSeverity.SAFE

        val reasons = mutableListOf("Wi-Fi network connection configuration decoded")
        if (isNoPass) {
            reasons.add("Unencrypted open Wi-Fi network configuration (vulnerable to Man-In-The-Middle packet interception)")
        } else {
            reasons.add("WPA/WPA2/WPA3 password-protected network credentials")
        }

        return QrThreatEvaluation(
            rawPayload = rawUri,
            payloadType = QrPayloadType.WIFI_CONFIG,
            isUrl = false,
            isPaymentOrDeepLink = false,
            urlEvaluation = null,
            paymentDetails = null,
            riskScore = score,
            severity = severity,
            reasons = reasons,
            recommendation = if (isNoPass) "Avoid connecting to unencrypted open public Wi-Fi networks." else "Verify Wi-Fi router ownership before connecting.",
            warningTitle = if (isNoPass) "UNENCRYPTED WI-FI WARNING" else "WI-FI CONFIGURATION DETECTED",
            warningMessage = if (isNoPass) "Connecting to open Wi-Fi allows adjacent network devices to snoop on unencrypted traffic." else "This QR code contains Wi-Fi access credentials.",
            requiresExplicitConsentToOpen = true
        )
    }

    private fun evaluatePlainTextPayload(text: String): QrThreatEvaluation {
        val isLikelyKey = text.length >= 32 && (text.contains("BEGIN PRIVATE KEY") || text.matches(Regex("^[a-fA-F0-9]{64}$")))
        val score = if (isLikelyKey) 70 else 0
        val severity = if (isLikelyKey) RiskSeverity.HIGH else RiskSeverity.SAFE

        val reasons = if (isLikelyKey) {
            listOf("Plaintext contains cryptographic private key or seed signature; high risk of credential compromise")
        } else {
            listOf("Standard text payload with no executable schemes or hyperlink routes")
        }

        return QrThreatEvaluation(
            rawPayload = text,
            payloadType = QrPayloadType.PLAIN_TEXT,
            isUrl = false,
            isPaymentOrDeepLink = false,
            urlEvaluation = null,
            paymentDetails = null,
            riskScore = score,
            severity = severity,
            reasons = reasons,
            recommendation = if (isLikelyKey) "Never share or display private keys in physical QR form." else "Payload contains plain text data.",
            warningTitle = "PLAIN TEXT CONTENT",
            warningMessage = "Decoded non-executable text content.",
            requiresExplicitConsentToOpen = false
        )
    }

    private fun createEmptyEvaluation() = QrThreatEvaluation(
        rawPayload = "",
        payloadType = QrPayloadType.PLAIN_TEXT,
        isUrl = false,
        isPaymentOrDeepLink = false,
        urlEvaluation = null,
        paymentDetails = null,
        riskScore = 0,
        severity = RiskSeverity.SAFE,
        reasons = listOf("Empty payload"),
        recommendation = "No action required.",
        warningTitle = null,
        warningMessage = null,
        requiresExplicitConsentToOpen = false
    )
}
