package com.cyberguard.xai.domain.model

import com.cyberguard.xai.presentation.components.RiskSeverity

enum class AiContextType(val title: String) {
    PASTED_MESSAGE("Pasted Message"),
    URL("Target URL"),
    SCREENSHOT("Screenshot Forensic"),
    THREAT_ID("Security Event ID"),
    QR_RESULT("QR Code Payload"),
    CALL_RISK("Call Risk Analysis"),
    NONE("General Question")
}

data class AiAttachedContext(
    val type: AiContextType,
    val title: String,
    val content: String,
    val preview: String = content.take(60),
    val metadata: Map<String, String> = emptyMap()
)

data class AiResponseStructured(
    val risk: String,
    val severity: RiskSeverity,
    val evidence: List<String>,
    val explanation: String,
    val recommendedAction: String,
    val confidence: String,
    val isCertaintyClaimed: Boolean = false
)

data class AiChatMessage(
    val id: String,
    val conversationId: String,
    val sender: String, // "user" or "assistant"
    val content: String,
    val attachedContext: AiAttachedContext? = null,
    val structuredResponse: AiResponseStructured? = null,
    val timestamp: Long = System.currentTimeMillis()
)
