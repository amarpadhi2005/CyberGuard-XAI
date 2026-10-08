package com.cyberguard.xai.core.rules

import com.cyberguard.xai.domain.model.QrPayloadType
import com.cyberguard.xai.domain.model.QrThreatEvaluation
import com.cyberguard.xai.domain.model.UrlThreatEvaluation
import com.cyberguard.xai.domain.model.XaiSignal
import com.cyberguard.xai.domain.model.XaiThreatResult
import com.cyberguard.xai.presentation.components.RiskSeverity

object XaiExplainerFactory {

    fun fromUrlEvaluation(eval: UrlThreatEvaluation): XaiThreatResult {
        val signals = mutableListOf<XaiSignal>()
        val evidence = mutableListOf<String>()

        if (eval.isKnownThreat) {
            signals.add(
                XaiSignal(
                    name = "Threat Intelligence Blacklist",
                    category = "Threat Intelligence",
                    scoreImpact = 100,
                    isPositive = false,
                    description = "Target host matches active confirmed malicious/phishing infrastructure signatures in global registry."
                )
            )
            evidence.add("Domain '${eval.domain}' is listed on active cybercrime blacklists.")
        }

        if (eval.hasLookalikeDomain && eval.lookalikeTarget != null) {
            signals.add(
                XaiSignal(
                    name = "Typosquatting Brand Impersonation",
                    category = "Domain Governance",
                    scoreImpact = 45,
                    isPositive = false,
                    description = "Character substitution or homoglyphs intentionally mimics '${eval.lookalikeTarget}' to deceive users."
                )
            )
            evidence.add("Hostname spoofing targeting legitimate brand '${eval.lookalikeTarget}'.")
        }

        if (eval.isIpAddress) {
            signals.add(
                XaiSignal(
                    name = "Raw IP Host Address",
                    category = "Network & Transport",
                    scoreImpact = 40,
                    isPositive = false,
                    description = "Host uses a raw numerical IPv4 address (${eval.domain}), bypassing standard domain registration and WHOIS accountability."
                )
            )
            evidence.add("Direct numerical IP host without verifiable domain ownership.")
        }

        if (eval.hasSuspiciousTld) {
            signals.add(
                XaiSignal(
                    name = "High-Abuse Top Level Domain",
                    category = "Domain Governance",
                    scoreImpact = 30,
                    isPositive = false,
                    description = "TLD exhibits elevated abuse and low-barrier domain registration frequently leveraged by automated spam networks."
                )
            )
            evidence.add("Top-level domain categorized as high-abuse vector.")
        }

        if (!eval.isHttps) {
            val impact = if (eval.hasSuspiciousPath) 30 else 15
            signals.add(
                XaiSignal(
                    name = "Unencrypted Cleartext Transport",
                    category = "Network & Transport",
                    scoreImpact = impact,
                    isPositive = false,
                    description = "Connection uses unencrypted HTTP; traffic is vulnerable to eavesdropping and Man-In-The-Middle manipulation."
                )
            )
            evidence.add("HTTP cleartext transmission lacks TLS/SSL encryption.")
        } else {
            signals.add(
                XaiSignal(
                    name = "Valid TLS/HTTPS Encryption",
                    category = "Network & Transport",
                    scoreImpact = -10,
                    isPositive = true,
                    description = "Connection is encrypted using standard Transport Layer Security (TLS)."
                )
            )
        }

        if (eval.hasExcessiveSubdomains) {
            signals.add(
                XaiSignal(
                    name = "Excessive Subdomain Depth",
                    category = "Domain Governance",
                    scoreImpact = 25,
                    isPositive = false,
                    description = "${eval.subdomainCount} subdomains detected. Threat actors use extended subdomains to push true domains off mobile address bars."
                )
            )
            evidence.add("Excessive subdomain depth hides authoritative domain root.")
        }

        if (eval.hasSuspiciousPath) {
            signals.add(
                XaiSignal(
                    name = "Sensitive Authentication Route",
                    category = "Behavioral Heuristics",
                    scoreImpact = 20,
                    isPositive = false,
                    description = "URL route targets login, banking, or verification keywords on an untrusted origin."
                )
            )
            evidence.add("Route contains sensitive credential keywords or executable file extensions.")
        }

        if (eval.isShortened) {
            signals.add(
                XaiSignal(
                    name = "URL Obfuscation Shortener",
                    category = "Behavioral Heuristics",
                    scoreImpact = 20,
                    isPositive = false,
                    description = "Destination concealed through link shortening service (${eval.domain})."
                )
            )
            evidence.add("URL shortener conceals ultimate landing endpoint.")
        }

        if (signals.isEmpty() || eval.riskScore == 0) {
            signals.add(
                XaiSignal(
                    name = "Clean Domain Reputation",
                    category = "Reputation",
                    scoreImpact = 0,
                    isPositive = true,
                    description = "No anomalous homoglyphs, threat blacklist hits, or unencrypted credential flows detected."
                )
            )
            evidence.add("Clean domain reputation and standard HTTPS security configuration.")
        }

        val decision = when {
            eval.riskScore >= 70 -> "BLOCK_THREAT"
            eval.riskScore >= 50 -> "FLAG_SUSPICIOUS"
            eval.riskScore >= 25 -> "USER_VERIFICATION_REQUIRED"
            else -> "ALLOW_SAFE"
        }

        val confidence = when {
            eval.isKnownThreat -> "99% (Confirmed Blacklist Match)"
            eval.hasLookalikeDomain -> "95% (High Typo-Signature Overlap)"
            eval.riskScore >= 70 -> "91% (High Multi-Vector Correlation)"
            eval.riskScore in 25..69 -> "76% (Moderate Behavioral Risk)"
            else -> "92% (High Confidence Clean Baseline)"
        }

        return XaiThreatResult(
            riskScore = eval.riskScore,
            severity = eval.severity,
            decision = decision,
            evidence = evidence,
            signals = signals,
            confidence = confidence,
            recommendedAction = eval.recommendation,
            title = "URL Threat Analysis",
            targetEntity = eval.normalizedUrl
        )
    }

    fun fromQrEvaluation(eval: QrThreatEvaluation): XaiThreatResult {
        if (eval.isUrl && eval.urlEvaluation != null) {
            val baseResult = fromUrlEvaluation(eval.urlEvaluation)
            val updatedSignals = baseResult.signals.toMutableList()
            val updatedEvidence = baseResult.evidence.toMutableList()

            if (eval.rawPayload.endsWith(".apk", ignoreCase = true)) {
                updatedSignals.add(
                    0,
                    XaiSignal(
                        name = "Direct APK Package Download",
                        category = "Malware Distribution",
                        scoreImpact = 30,
                        isPositive = false,
                        description = "QR link triggers immediate download of an unsigned Android application package."
                    )
                )
                updatedEvidence.add("QR links directly to Android APK executable package.")
            }

            return baseResult.copy(
                title = "QR Code URL Forensic Scan",
                targetEntity = eval.rawPayload,
                signals = updatedSignals,
                evidence = updatedEvidence,
                recommendedAction = eval.recommendation
            )
        }

        val signals = mutableListOf<XaiSignal>()
        val evidence = mutableListOf<String>()

        when (eval.payloadType) {
            QrPayloadType.PAYMENT_UPI -> {
                val details = eval.paymentDetails
                signals.add(
                    XaiSignal(
                        name = "UPI Payment Transfer Intent",
                        category = "Financial Transactions",
                        scoreImpact = 45,
                        isPositive = false,
                        description = "Launches payment apps with intent to debit funds from the user's account."
                    )
                )
                evidence.add("Decoded UPI payment intent targeting payee '${details?.payeeAddress ?: "Unknown"}'.")

                if (details?.isDeceptivePayee == true) {
                    signals.add(
                        0,
                        XaiSignal(
                            name = "Imposter Support Payee Name",
                            category = "Identity & Impersonation",
                            scoreImpact = 35,
                            isPositive = false,
                            description = "Payee name '${details.payeeName}' uses keywords matching customer support or official verification departments."
                        )
                    )
                    evidence.add("Payee name mimics official institutional authority.")
                }

                if (!details?.amount.isNullOrBlank()) {
                    signals.add(
                        XaiSignal(
                            name = "Pre-filled Debit Amount",
                            category = "Financial Transactions",
                            scoreImpact = 20,
                            isPositive = false,
                            description = "QR specifies pre-set debit of ${details?.currency} ${details?.amount} without prior invoice confirmation."
                        )
                    )
                    evidence.add("Auto-filled deduction amount: ${details?.currency} ${details?.amount}.")
                }
            }

            QrPayloadType.PAYMENT_CRYPTO -> {
                signals.add(
                    XaiSignal(
                        name = "Irreversible Cryptocurrency Transfer",
                        category = "Financial Transactions",
                        scoreImpact = 55,
                        isPositive = false,
                        description = "Direct transfer to public blockchain address; transactions cannot be reversed or refunded."
                    )
                )
                evidence.add("Target is a non-reversible cryptocurrency wallet address.")
            }

            QrPayloadType.DEEP_LINK -> {
                signals.add(
                    XaiSignal(
                        name = "Arbitrary App Intent Execution",
                        category = "System & Execution",
                        scoreImpact = 70,
                        isPositive = false,
                        description = "QR initiates explicit Android intent, potentially invoking vulnerable exported components or triggering APK installation."
                    )
                )
                evidence.add("Deep-link executes external system intent.")
            }

            else -> {
                signals.add(
                    XaiSignal(
                        name = "Standard Payload",
                        category = "Baseline",
                        scoreImpact = 0,
                        isPositive = true,
                        description = "No anomalous financial or execution vectors present."
                    )
                )
                evidence.add("Standard text payload.")
            }
        }

        val decision = when {
            eval.riskScore >= 70 -> "BLOCK_THREAT"
            eval.riskScore >= 50 -> "FLAG_SUSPICIOUS"
            eval.riskScore >= 25 -> "USER_VERIFICATION_REQUIRED"
            else -> "ALLOW_SAFE"
        }

        return XaiThreatResult(
            riskScore = eval.riskScore,
            severity = eval.severity,
            decision = decision,
            evidence = evidence,
            signals = signals,
            confidence = if (eval.riskScore >= 70) "94% (High Confidence)" else "78% (Moderate Confidence)",
            recommendedAction = eval.recommendation,
            title = "QR Code Scam Analysis",
            targetEntity = eval.rawPayload
        )
    }

    fun createSimulatedIncident(
        title: String,
        source: String,
        targetEntity: String,
        riskScore: Int
    ): XaiThreatResult {
        val severity = when {
            riskScore >= 85 -> RiskSeverity.CRITICAL
            riskScore >= 70 -> RiskSeverity.HIGH
            riskScore >= 50 -> RiskSeverity.MEDIUM
            riskScore >= 25 -> RiskSeverity.LOW
            else -> RiskSeverity.SAFE
        }

        val signals = listOf(
            XaiSignal(
                name = "Typosquatting Lexical Distance",
                category = "Domain Governance",
                scoreImpact = 45,
                isPositive = false,
                description = "Target domain 'paypa1-update.com' deviates by 1 character substitution (1 for l) from authenticated brand."
            ),
            XaiSignal(
                name = "High-Risk Top Level Domain (.top)",
                category = "Domain Governance",
                scoreImpact = 30,
                isPositive = false,
                description = "Registrar ASN correlates with bulletproof hosting and high spam activity."
            ),
            XaiSignal(
                name = "NLP Urgency Coercion Signature",
                category = "Behavioral NLP",
                scoreImpact = 25,
                isPositive = false,
                description = "Sender message employs high-pressure psychological language ('Account suspended in 2 hours')."
            )
        )

        val evidence = listOf(
            "SMS received from unverified international virtual number.",
            "Contains deceptive link masquerading as institutional account portal.",
            "Destination domain was registered within the past 48 hours."
        )

        return XaiThreatResult(
            riskScore = riskScore,
            severity = severity,
            decision = "BLOCK_THREAT",
            evidence = evidence,
            signals = signals,
            confidence = "96% (High Confidence - Multi-Signal Correlation)",
            recommendedAction = "Do not open link or disclose account verification passcodes. Domain added to active blocklist.",
            title = title,
            targetEntity = targetEntity
        )
    }
}
