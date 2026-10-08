package com.cyberguard.xai.data.repository.threats

import com.cyberguard.xai.domain.model.ThreatCampaignUiModel
import com.cyberguard.xai.domain.model.TimelineStepUiModel
import com.cyberguard.xai.presentation.components.RiskSeverity
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

object ThreatDnaRepository {

    private val _selectedTimeWindowHours = MutableStateFlow(24)
    val selectedTimeWindowHours: StateFlow<Int> = _selectedTimeWindowHours.asStateFlow()

    private val _activeCampaign = MutableStateFlow<ThreatCampaignUiModel?>(null)
    val activeCampaign: StateFlow<ThreatCampaignUiModel?> = _activeCampaign.asStateFlow()

    init {
        // Initialize default correlated multi-vector campaign
        recalculateCampaign(24)
    }

    fun setTimeWindow(hours: Int) {
        _selectedTimeWindowHours.value = hours
        recalculateCampaign(hours)
    }

    fun recalculateCampaign(hours: Int) {
        // Example multi-vector attack chain matching specification:
        // suspicious call + suspicious notification + suspicious URL + QR payment request
        val timeline = listOf(
            TimelineStepUiModel(
                stepNumber = 1,
                elapsedTime = "T+00m",
                timestampFormatted = "38m ago",
                vector = "SUSPICIOUS CALL",
                vectorIconType = "CALL",
                title = "VoIP Caller Spoof (IRS / Fraud Prevention)",
                source = "+1 (800) 555-0199",
                riskScore = 72,
                severity = RiskSeverity.HIGH,
                evidenceSnippet = "Unallocated toll-free exchange with automated voice synthesizer mimicking urgent fraud alert."
            ),
            TimelineStepUiModel(
                stepNumber = 2,
                elapsedTime = "T+03m",
                timestampFormatted = "35m ago",
                vector = "SUSPICIOUS NOTIFICATION",
                vectorIconType = "SMS",
                title = "Coercive Account Lock Smishing SMS",
                source = "com.google.android.apps.messaging",
                riskScore = 85,
                severity = RiskSeverity.CRITICAL,
                evidenceSnippet = "Urgent notification received 3 minutes after call, claiming immediate 24h account suspension."
            ),
            TimelineStepUiModel(
                stepNumber = 3,
                elapsedTime = "T+18m",
                timestampFormatted = "20m ago",
                vector = "SUSPICIOUS URL",
                vectorIconType = "URL",
                title = "Typosquatted Credential Harvester",
                source = "paypa1-account-security.top",
                riskScore = 92,
                severity = RiskSeverity.CRITICAL,
                evidenceSnippet = "Link from notification navigated to typosquatted domain hosted on unencrypted cleartext endpoint."
            ),
            TimelineStepUiModel(
                stepNumber = 4,
                elapsedTime = "T+34m",
                timestampFormatted = "4m ago",
                vector = "QR PAYMENT REQUEST",
                vectorIconType = "QR",
                title = "Pre-filled Fraudulent Debit QR",
                source = "Optical Scanner Intercept",
                riskScore = 88,
                severity = RiskSeverity.HIGH,
                evidenceSnippet = "Embedded QR on phishing portal prompts $500 UPI/crypto debit under guise of account unlock fee."
            )
        )

        // Filter events that fall within the configured window
        // (For demo purposes: 2h/6h/24h/48h contain the 38-minute cluster)
        val filteredTimeline = if (hours >= 1) timeline else emptyList()

        val baselineRisk = filteredTimeline.maxOfOrNull { it.riskScore } ?: 0
        val escalationDelta = if (filteredTimeline.size >= 4) 24 else if (filteredTimeline.size >= 2) 15 else 0
        val escalatedRisk = (baselineRisk + escalationDelta).coerceAtMost(98)

        _activeCampaign.value = ThreatCampaignUiModel(
            campaignId = "DNA-CMP-7E3D1A",
            dnaFingerprint = "DNA:CALL+SMS+URL+QR:PAYPAL:T-38M",
            correlationStatus = "Possible Related Activity",
            vectorsInvolved = listOf("VoIP Call", "Smishing Notification", "Phishing URL", "Payment QR"),
            eventCount = filteredTimeline.size,
            timeSpanMinutes = 38,
            baselineRiskScore = baselineRisk,
            escalatedRiskScore = escalatedRisk,
            escalationDelta = escalationDelta,
            escalationReason = "+$escalationDelta Points: Multi-vector convergence across 4 distinct communication channels within 38 minutes.",
            confidence = 0.88f,
            correlationEvidence = listOf(
                "Temporal Clustering: 4 intercepted events occurred within a concentrated 38-minute window.",
                "Sequential Intent Progression: Attack progressed from initial VoIP lure to SMS notification, credential harvesting URL, and financial QR execution.",
                "Target Branding Consistency: All artifacts coordinated under simulated 'PayPal' security lock lures.",
                "Forensic Classification: Heuristic indicators exhibit synchronized social engineering patterns ('possible related activity')."
            ),
            timeline = filteredTimeline,
            recommendedActionPlaybook = listOf(
                "Block origin phone number (+1 800 555-0199) and report CLI caller-ID spoofing.",
                "Blacklist 'paypa1-account-security.top' and clear mobile browser cache.",
                "Reject and discard pending pre-filled UPI payment request; do not enter banking PIN.",
                "Review authorized sessions in genuine financial portal directly via official app."
            ),
            disclaimer = "Attribution Notice: Events are correlated on temporal clustering and heuristic proximity. In accordance with forensic best practices, this is classified as 'possible related activity' rather than a confirmed single threat actor without cryptographic infrastructure proof."
        )
    }
}
