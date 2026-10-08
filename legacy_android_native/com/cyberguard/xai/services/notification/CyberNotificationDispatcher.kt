package com.cyberguard.xai.services.notification

import android.content.Context
import com.cyberguard.xai.presentation.components.RiskSeverity

/**
 * Dispatcher for local threat alerts, delegating directly to ThreatNotificationManager
 * and NotificationChannelManager.
 */
object CyberNotificationDispatcher {

    const val CHANNEL_ID = NotificationChannelManager.CHANNEL_CRITICAL_THREATS

    fun createNotificationChannel(context: Context) {
        NotificationChannelManager.createAllChannels(context)
    }

    fun showThreatWarning(
        context: Context,
        threatId: String,
        title: String,
        source: String,
        threatType: String,
        riskScore: Int,
        xaiSummary: String = "Intercepted by local heuristic rule engine. Risk Score: $riskScore/100."
    ) {
        val severity = when {
            riskScore >= 85 -> RiskSeverity.CRITICAL
            riskScore >= 70 -> RiskSeverity.HIGH
            riskScore >= 50 -> RiskSeverity.MEDIUM
            else -> RiskSeverity.LOW
        }

        ThreatNotificationManager.showThreatNotification(
            context = context,
            threatId = threatId,
            title = title,
            source = source,
            threatType = threatType,
            riskScore = riskScore,
            xaiExplanation = xaiSummary,
            severity = severity
        )
    }
}
