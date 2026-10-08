package com.cyberguard.xai.domain.model

import com.cyberguard.xai.presentation.components.RiskSeverity

data class TimelineStepUiModel(
    val stepNumber: Int,
    val elapsedTime: String,        // e.g. "T+00m", "T+03m", "T+18m", "T+34m"
    val timestampFormatted: String, // e.g. "38m ago", "35m ago"
    val vector: String,             // "VOIP CALL", "SMISHING SMS", "PHISHING URL", "QR PAYMENT"
    val vectorIconType: String,     // "CALL", "SMS", "URL", "QR"
    val title: String,
    val source: String,
    val riskScore: Int,
    val severity: RiskSeverity,
    val evidenceSnippet: String
)

data class ThreatCampaignUiModel(
    val campaignId: String,          // e.g. "DNA-CMP-7E3D1A"
    val dnaFingerprint: String,       // e.g. "DNA:CALL+SMS+URL+QR:PAYPAL:T-38M"
    val correlationStatus: String,   // "Possible Related Activity"
    val vectorsInvolved: List<String>,
    val eventCount: Int,
    val timeSpanMinutes: Int,
    val baselineRiskScore: Int,
    val escalatedRiskScore: Int,
    val escalationDelta: Int,
    val escalationReason: String,
    val confidence: Float,
    val correlationEvidence: List<String>,
    val timeline: List<TimelineStepUiModel>,
    val recommendedActionPlaybook: List<String>,
    val disclaimer: String
)
