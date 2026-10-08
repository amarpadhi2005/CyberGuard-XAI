package com.cyberguard.xai.domain.model

import com.cyberguard.xai.presentation.components.RiskSeverity

data class XaiSignal(
    val name: String,
    val category: String, // e.g., "Domain Governance", "Network & Transport", "Behavioral NLP", "Threat Intelligence"
    val scoreImpact: Int, // e.g., +45, +30, -10
    val isPositive: Boolean = false, // true = mitigating/safe signal (reduces risk), false = risk signal
    val description: String
)

data class XaiThreatResult(
    val riskScore: Int, // 0-100
    val severity: RiskSeverity,
    val decision: String, // "BLOCK_THREAT", "FLAG_SUSPICIOUS", "ALLOW_SAFE", "QUARANTINE"
    val evidence: List<String>,
    val signals: List<XaiSignal>,
    val confidence: String,
    val recommendedAction: String,
    val title: String? = null,
    val targetEntity: String? = null
)
