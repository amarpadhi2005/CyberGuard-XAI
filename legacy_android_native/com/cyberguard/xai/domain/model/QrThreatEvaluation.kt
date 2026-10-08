package com.cyberguard.xai.domain.model

import com.cyberguard.xai.presentation.components.RiskSeverity

enum class QrPayloadType {
    URL,
    PAYMENT_UPI,
    PAYMENT_CRYPTO,
    PAYMENT_WALLET,
    DEEP_LINK,
    WIFI_CONFIG,
    PLAIN_TEXT
}

data class QrPaymentDetails(
    val scheme: String,
    val payeeAddress: String? = null,
    val payeeName: String? = null,
    val amount: String? = null,
    val currency: String? = null,
    val transactionNote: String? = null,
    val isDeceptivePayee: Boolean = false
)

data class QrThreatEvaluation(
    val rawPayload: String,
    val payloadType: QrPayloadType,
    val isUrl: Boolean,
    val isPaymentOrDeepLink: Boolean,
    val urlEvaluation: UrlThreatEvaluation? = null,
    val paymentDetails: QrPaymentDetails? = null,
    val riskScore: Int, // 0-100
    val severity: RiskSeverity,
    val reasons: List<String>,
    val recommendation: String,
    val warningTitle: String? = null,
    val warningMessage: String? = null,
    val requiresExplicitConsentToOpen: Boolean = true
)
