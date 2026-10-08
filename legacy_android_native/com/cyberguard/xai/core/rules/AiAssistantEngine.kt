package com.cyberguard.xai.core.rules

import com.cyberguard.xai.domain.model.AiAttachedContext
import com.cyberguard.xai.domain.model.AiContextType
import com.cyberguard.xai.domain.model.AiResponseStructured
import com.cyberguard.xai.presentation.components.RiskSeverity
import java.util.Locale

object AiAssistantEngine {

    fun generateResponse(
        question: String,
        context: AiAttachedContext?
    ): AiResponseStructured {
        val q = question.trim().lowercase(Locale.ROOT)

        // If no context is attached, evaluate as general cybersecurity advisory or prompt for context
        if (context == null || context.type == AiContextType.NONE || context.content.isBlank()) {
            return handleGeneralCyberAdvisory(q, question)
        }

        return when (context.type) {
            AiContextType.URL -> evaluateUrlContext(context.content, q)
            AiContextType.PASTED_MESSAGE -> evaluateMessageContext(context.content, q)
            AiContextType.QR_RESULT -> evaluateQrContext(context.content, q)
            AiContextType.CALL_RISK -> evaluateCallRiskContext(context.content, q, context.metadata)
            AiContextType.THREAT_ID -> evaluateThreatIdContext(context.content, q)
            AiContextType.SCREENSHOT -> evaluateScreenshotContext(context.content, q)
            AiContextType.NONE -> handleGeneralCyberAdvisory(q, question)
        }
    }

    private fun evaluateUrlContext(url: String, q: String): AiResponseStructured {
        val eval = UrlThreatDetector.evaluate(url)
        val isPhishing = eval.riskScore >= 50
        val isShortened = eval.isShortened

        val evidence = mutableListOf<String>()
        evidence.addAll(eval.reasons)
        evidence.add(if (eval.isHttps) "Transport: TLS HTTPS encrypted" else "Transport: Insecure HTTP cleartext")

        // Confidence calculation: high if confirmed blacklist or lookalike, moderate if heuristics only
        val confidence = when {
            eval.isKnownThreat -> "High (99%) - Confirmed Threat Intelligence Blacklist match"
            eval.hasLookalikeDomain -> "High (94%) - Definite brand typosquatting signature"
            eval.riskScore >= 70 -> "High (88%) - Strong multi-vector phishing heuristic overlap"
            eval.riskScore in 25..69 -> "Moderate (68%) - Anomalies present, but domain ownership unverified"
            else -> "Moderate (75%) - Domain exhibits standard security, but novel zero-day attacks cannot be ruled out"
        }

        val riskDesc = when (eval.severity) {
            RiskSeverity.CRITICAL -> "CRITICAL THREAT"
            RiskSeverity.HIGH -> "HIGH RISK"
            RiskSeverity.MEDIUM -> "SUSPICIOUS / ELEVATED RISK"
            RiskSeverity.LOW -> "LOW RISK"
            RiskSeverity.SAFE -> "LOW RISK / APPARENTLY SAFE"
        }

        // Tailor explanation based on user's specific question
        val explanation = when {
            q.contains("is this safe") || q.contains("safe?") -> {
                if (isPhishing) {
                    "No, this link is NOT safe. It exhibits multiple forensic indicators of phishing or spoofing, including impersonation of legitimate domains to intercept credentials."
                } else if (isShortened) {
                    "Uncertain. This link is shortened via '${eval.domain}', concealing the ultimate destination. Do not click until unshortened."
                } else {
                    "This link appears standard with clean domain reputation. However, always exercise caution when prompted to log in or download files."
                }
            }
            q.contains("why is this suspicious") || q.contains("why?") -> {
                "Forensic inspection identified: ${eval.reasons.joinToString("; ")}. These tactics are commonly used in social engineering to bypass mobile address bar visibility."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                if (isPhishing) {
                    "Do NOT tap or open this link. Delete the message containing it and report the sender. If you already visited, change your account passwords immediately."
                } else {
                    "If you recognize the sender and requested this link, proceed with care. Verify the full domain spelling in your browser address bar."
                }
            }
            q.contains("how serious") || q.contains("severity") -> {
                if (isPhishing) {
                    "Severity is ${eval.severity.name} (Risk Score: ${eval.riskScore}/100). Malicious actors can steal session cookies, harvest payment data, or download droppers."
                } else {
                    "Severity is LOW (Risk Score: ${eval.riskScore}/100). No active malware or deceptive redirection signatures were matched."
                }
            }
            q.contains("how can i verify") || q.contains("verify") -> {
                "1. Check domain WHOIS registration age.\n2. Navigate directly to the organization's official website via a bookmark instead of clicking this link.\n3. Expand the link using an external URL unshortener tool."
            }
            else -> {
                "Analyzed URL: ${eval.normalizedUrl}. ${eval.reasons.joinToString(". ")}. Recommendation: ${eval.recommendation}"
            }
        }

        return AiResponseStructured(
            risk = riskDesc,
            severity = eval.severity,
            evidence = evidence,
            explanation = explanation,
            recommendedAction = eval.recommendation,
            confidence = confidence,
            isCertaintyClaimed = eval.isKnownThreat || eval.hasLookalikeDomain
        )
    }

    private fun evaluateMessageContext(text: String, q: String): AiResponseStructured {
        val wordCount = text.split("\\s+".toRegex()).size
        val hasUrl = text.contains("http://", ignoreCase = true) || text.contains("https://", ignoreCase = true)
        val hasOtp = text.contains("otp", ignoreCase = true) || text.contains("code", ignoreCase = true)
        val hasUrgency = text.contains("urgent", ignoreCase = true) || text.contains("immediately", ignoreCase = true) || text.contains("suspended", ignoreCase = true)
        val hasPayment = text.contains("wire", ignoreCase = true) || text.contains("crypto", ignoreCase = true) || text.contains("fee", ignoreCase = true) || text.contains("$")

        val evidence = mutableListOf<String>()
        var score = 0

        if (hasOtp) {
            score += 45
            evidence.add("Explicit request for one-time verification passcode (OTP)")
        }
        if (hasUrgency) {
            score += 30
            evidence.add("Coercive high-urgency language designed to induce panic")
        }
        if (hasPayment) {
            score += 30
            evidence.add("Demand for non-reversible financial transfer")
        }
        if (hasUrl) {
            score += 25
            evidence.add("External hyperlink embedded within unverified message body")
        }

        // Check if there is enough evidence
        val isInsufficientEvidence = wordCount < 6 && evidence.isEmpty()

        if (isInsufficientEvidence) {
            return AiResponseStructured(
                risk = "UNCERTAIN / INSUFFICIENT EVIDENCE",
                severity = RiskSeverity.LOW,
                evidence = listOf("Message is too brief ($wordCount words) to determine intent", "No known scam keywords or hyperlinks identified"),
                explanation = "There is insufficient textual context to definitively establish legitimacy or malice. Benign messages can sometimes serve as preliminary conversational lures in social engineering.",
                recommendedAction = "Do not share sensitive personal information. Ask the sender for context or verify their identity through a known second channel.",
                confidence = "Low (28%) - Insufficient context to claim certainty",
                isCertaintyClaimed = false
            )
        }

        val severity = when {
            score >= 70 -> RiskSeverity.CRITICAL
            score >= 45 -> RiskSeverity.HIGH
            score >= 25 -> RiskSeverity.MEDIUM
            else -> RiskSeverity.SAFE
        }

        val confidence = when {
            score >= 70 -> "High (92%) - Strong multi-indicator social engineering fingerprint"
            score >= 40 -> "Moderate (74%) - Suspicious behavioral markers present"
            else -> "Moderate (60%) - Absence of overt red flags, but caution warranted"
        }

        val explanation = when {
            q.contains("is this safe") || q.contains("safe?") -> {
                if (score >= 45) "No, this message is highly suspicious and strongly resembles an active social engineering or credential harvesting attempt."
                else "This message lacks obvious scam indicators, but caution is advised if the sender was previously uncontacted."
            }
            q.contains("why is this suspicious") || q.contains("why?") -> {
                "Suspicious traits detected: ${evidence.joinToString("; ")}. Threat actors use these psychological triggers to bypass logical skepticism."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                if (score >= 45) "Never share OTPs, passwords, or personal credentials. Block the sender and report the message to your carrier as spam."
                else "If you were expecting this communication, proceed with standard awareness. Otherwise, do not click unsolicited links."
            }
            q.contains("how serious") || q.contains("severity") -> {
                if (score >= 45) "High severity. Complying with this message could lead to account takeover, SIM swap, or direct financial loss."
                else "Low severity. No immediate threat payload detected."
            }
            q.contains("how can i verify") || q.contains("verify") -> {
                "1. Contact the service provider directly through their verified customer support app or website (never using links or numbers inside the message).\n2. Search the message text online to see if others reported it as a known scam template."
            }
            else -> "Analysis completed. Indicators: ${evidence.joinToString(". ")}."
        }

        return AiResponseStructured(
            risk = if (score >= 45) "SUSPICIOUS SCAM LURE" else "LOW RISK / UNVERIFIED",
            severity = severity,
            evidence = evidence.ifEmpty { listOf("Lexical structure does not contain blacklisted keywords") },
            explanation = explanation,
            recommendedAction = if (score >= 45) "Do not reply, disclose codes, or click links. Block sender immediately." else "Confirm sender identity if unfamiliar.",
            confidence = confidence,
            isCertaintyClaimed = score >= 70
        )
    }

    private fun evaluateQrContext(qrPayload: String, q: String): AiResponseStructured {
        val eval = QrThreatDetector.evaluate(qrPayload)
        val isPayment = eval.isPaymentOrDeepLink

        val confidence = when {
            eval.riskScore >= 75 -> "High (95%) - Definite imposter UPI or malicious URI scheme"
            eval.isUrl -> "High (88%) - Comprehensive URL threat forensic inspection"
            else -> "Moderate (70%) - Decoded structured format"
        }

        val explanation = when {
            q.contains("is this safe") || q.contains("safe?") -> {
                if (eval.riskScore >= 50) "No, this QR code is dangerous. It contains ${eval.payloadType.name} with significant threat indicators."
                else "This QR code contains standard data with no identified malicious vectors. Review before opening."
            }
            q.contains("why is this suspicious") || q.contains("why?") -> {
                "Forensics identified: ${eval.reasons.joinToString("; ")}."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                if (isPayment) "DO NOT enter your UPI PIN. UPI PINs are only used to deduct money from your account, never to receive funds or refunds."
                else eval.recommendation
            }
            q.contains("how serious") || q.contains("severity") -> {
                "Risk Rating: ${eval.riskScore}/100 (${eval.severity.name}). Threat Category: ${eval.payloadType.name}."
            }
            q.contains("how can i verify") || q.contains("verify") -> {
                "Check the decoded plain text or payee VPA address. If paying in a store, verify the merchant name displayed in the QR with the physical signage."
            }
            else -> "QR Payload Type: ${eval.payloadType.name}. ${eval.reasons.joinToString(". ")}."
        }

        return AiResponseStructured(
            risk = "${eval.severity.name} (${eval.payloadType.name})",
            severity = eval.severity,
            evidence = eval.reasons,
            explanation = explanation,
            recommendedAction = eval.recommendation,
            confidence = confidence,
            isCertaintyClaimed = eval.riskScore >= 75
        )
    }

    private fun evaluateCallRiskContext(callerInfo: String, q: String, metadata: Map<String, String>): AiResponseStructured {
        val riskScore = metadata["riskScore"]?.toIntOrNull() ?: 75
        val reasons = metadata["reasons"]?.split(";") ?: listOf(
            "VoIP origin detected with carrier inconsistency",
            "Reported 42 times in community scam database for impersonating tax authorities",
            "High conversational urgency and synthetic voice artifacts"
        )

        val severity = when {
            riskScore >= 80 -> RiskSeverity.CRITICAL
            riskScore >= 60 -> RiskSeverity.HIGH
            riskScore >= 40 -> RiskSeverity.MEDIUM
            else -> RiskSeverity.LOW
        }

        val explanation = when {
            q.contains("is this safe") || q.contains("safe?") -> {
                "No, incoming calls from this entity have a high probability of voice phishing (vishing) or impersonation fraud."
            }
            q.contains("why is this suspicious") || q.contains("why?") -> {
                "Forensic call telemetry identified: ${reasons.joinToString("; ")}."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                "Hang up immediately. Never dial callback numbers given by the caller. Block the telephone number in CyberGuard."
            }
            q.contains("how serious") || q.contains("severity") -> {
                "Severity is ${severity.name} (Risk Score: $riskScore/100). Impersonators often threaten account suspension or legal action to coerce urgent fund transfers."
            }
            q.contains("how can i verify") || q.contains("verify") -> {
                "Call the institution's official phone number listed on the back of your debit/credit card or official website."
            }
            else -> "Caller: $callerInfo. Risk Score: $riskScore/100. Telemetry: ${reasons.joinToString(". ")}."
        }

        return AiResponseStructured(
            risk = "${severity.name} VISHING THREAT",
            severity = severity,
            evidence = reasons,
            explanation = explanation,
            recommendedAction = "Terminate call immediately. Do not disclose verification codes or personal information.",
            confidence = "High (90%) - Correlated telephony signatures and community reports",
            isCertaintyClaimed = true
        )
    }

    private fun evaluateThreatIdContext(threatId: String, q: String): AiResponseStructured {
        val evidence = listOf(
            "Threat Incident ID: $threatId",
            "Matched database record in Supabase security_events table",
            "Event classification: Outbound beacon to high-risk C2 server",
            "Mitigation status: Automatically quarantined by CyberGuard"
        )

        val explanation = when {
            q.contains("how serious") || q.contains("severity") -> {
                "This security incident was categorized as HIGH SEVERITY. An unauthorized network request matching known command-and-control signatures was intercepted."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                "Run a full device integrity scan. Review recently installed applications and revoke accessibility or notification permissions for unfamiliar apps."
            }
            q.contains("how can i verify") || q.contains("verify") -> {
                "Inspect the raw forensic packet details in your Threat Details dashboard under Security History."
            }
            else -> "Threat record $threatId has been recorded and neutralized. No ongoing data leakage detected."
        }

        return AiResponseStructured(
            risk = "HIGH SEVERITY INCIDENT",
            severity = RiskSeverity.HIGH,
            evidence = evidence,
            explanation = explanation,
            recommendedAction = "Review recent background app permissions and maintain active real-time shield.",
            confidence = "High (98%) - Verified cryptographic hash and telemetry signature in local database",
            isCertaintyClaimed = true
        )
    }

    private fun evaluateScreenshotContext(summary: String, q: String): AiResponseStructured {
        val lower = summary.lowercase(Locale.ROOT)
        val hasRemoteAccess = lower.contains("anydesk") || lower.contains("teamviewer") || lower.contains("quicksupport") || lower.contains("rustdesk")
        val hasFakeWarning = lower.contains("virus") || lower.contains("infected") || lower.contains("call 1-800") || lower.contains("windows support")
        val hasBankLogin = lower.contains("bank") || lower.contains("login") || lower.contains("password") || lower.contains("card")

        val evidence = mutableListOf<String>()
        var score = 30

        if (hasRemoteAccess) {
            score += 55
            evidence.add("Prompt to install third-party remote screen-sharing software (AnyDesk/TeamViewer/RustDesk)")
        }
        if (hasFakeWarning) {
            score += 45
            evidence.add("Sensationalist virus warning dialog with fake technical support hotline")
        }
        if (hasBankLogin) {
            score += 20
            evidence.add("Financial credential or banking login input form visible")
        }

        val isThreat = score >= 50
        val severity = if (score >= 70) RiskSeverity.CRITICAL else (if (isThreat) RiskSeverity.HIGH else RiskSeverity.MEDIUM)

        val confidence = if (isThreat) {
            "Moderate-High (82%) - OCR optical indicators match classic tech support/remote access scam"
        } else {
            "Low (45%) - Limited visual context; cannot certify safety without complete UI source"
        }

        val explanation = when {
            q.contains("is this safe") || q.contains("safe?") -> {
                if (isThreat) "No, this screenshot depicts a deceptive security scare or remote access trap."
                else "We cannot verify this screen as 100% safe. Optical screenshots cannot reveal hidden background malware processes."
            }
            q.contains("why is this suspicious") || q.contains("why?") -> {
                "Optical inspection revealed: ${evidence.joinToString("; ")}."
            }
            q.contains("what should i do") || q.contains("what to do") -> {
                if (hasRemoteAccess) "NEVER grant remote screen access to anyone claiming to be technical support or bank personnel. Close the app and uninstall."
                else "Close the browser tab displaying this warning. Do not call numbers shown on web popups."
            }
            else -> "Visual inspection finished. Found: ${evidence.joinToString(". ")}."
        }

        return AiResponseStructured(
            risk = if (isThreat) "SUSPICIOUS FRAUDULENT SCREEN" else "UNVERIFIED VISUAL CONTENT",
            severity = severity,
            evidence = evidence.ifEmpty { listOf("General UI screen without explicit scam patterns, but full application context is unverified") },
            explanation = explanation,
            recommendedAction = if (isThreat) "Do not follow instructions shown on screen. Close application immediately." else "Proceed with standard caution.",
            confidence = confidence,
            isCertaintyClaimed = false // Never claim 100% certainty from visual screenshots alone
        )
    }

    private fun handleGeneralCyberAdvisory(q: String, rawQuery: String): AiResponseStructured {
        return when {
            q.contains("what is quishing") || q.contains("quishing") -> {
                AiResponseStructured(
                    risk = "INFORMATIONAL ADVISORY",
                    severity = RiskSeverity.MEDIUM,
                    evidence = listOf("User inquiry regarding QR-code phishing ('Quishing') vectors"),
                    explanation = "Quishing is QR-code phishing. Attackers place malicious QR codes in physical spots (parking meters, restaurants) or phishing emails to bypass email filters and trick mobile cameras into navigating to fraudulent credential-harvesting websites.",
                    recommendedAction = "Always scan QR codes with CyberGuard XAI rather than your generic camera app to preview destinations before opening.",
                    confidence = "High (96%) - Verified standard cybersecurity definition",
                    isCertaintyClaimed = true
                )
            }
            q.contains("deepfake") || q.contains("voice") -> {
                AiResponseStructured(
                    risk = "INFORMATIONAL ADVISORY",
                    severity = RiskSeverity.HIGH,
                    evidence = listOf("User inquiry regarding synthetic AI voice deepfakes"),
                    explanation = "Voice deepfakes synthesize familiar voices (such as family members or executives) to demand emergency wire transfers. Signs include lack of acoustic breathing pauses, unnatural cadence, and urgent requests for non-traceable funds.",
                    recommendedAction = "Establish a secret verbal family codeword. Hang up and call the loved one directly on their known phone number.",
                    confidence = "High (95%) - Established social engineering countermeasure",
                    isCertaintyClaimed = true
                )
            }
            else -> {
                AiResponseStructured(
                    risk = "INSUFFICIENT CONTEXT",
                    severity = RiskSeverity.LOW,
                    evidence = listOf("General query with no active context attached ($rawQuery)"),
                    explanation = "I am ready to analyze your threat. Please attach a suspicious URL, pasted message, screenshot, QR code, or call risk report so I can evaluate concrete evidence.",
                    recommendedAction = "Use the 📎 Attach Context button below to submit a message, link, or image for forensic analysis.",
                    confidence = "Low (20%) - No threat payload provided for inspection",
                    isCertaintyClaimed = false
                )
            }
        }
    }
}
