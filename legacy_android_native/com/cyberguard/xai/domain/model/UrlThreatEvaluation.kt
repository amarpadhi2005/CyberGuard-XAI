package com.cyberguard.xai.domain.model

import com.cyberguard.xai.presentation.components.RiskSeverity

data class UrlThreatEvaluation(
    val normalizedUrl: String,
    val domain: String,
    val isHttps: Boolean,
    val isIpAddress: Boolean,
    val isShortened: Boolean,
    val hasLookalikeDomain: Boolean,
    val lookalikeTarget: String?,
    val hasExcessiveSubdomains: Boolean,
    val subdomainCount: Int,
    val hasSuspiciousPath: Boolean,
    val hasSuspiciousTld: Boolean,
    val isKnownThreat: Boolean,
    val riskScore: Int, // 0-100
    val severity: RiskSeverity,
    val reasons: List<String>,
    val recommendation: String
)
