package com.cyberguard.xai.services.notification

import android.util.Log
import com.cyberguard.xai.core.network.CyberSupabaseClient
import com.cyberguard.xai.core.security.SecureStorage
import com.cyberguard.xai.data.repository.threats.ThreatStorage
import com.cyberguard.xai.presentation.components.RiskSeverity
import com.google.firebase.messaging.RemoteMessage
import io.github.jan.supabase.postgrest.postgrest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import java.util.UUID

/**
 * Handles Firebase Cloud Messaging (FCM) incoming signals for:
 * 1. Critical Threat Alerts (from backend cloud detection pipeline)
 * 2. Security Notifications (threat intelligence digests, scanner updates)
 * 3. Account Security Events (new logins, suspicious credential activity)
 *
 * NOTE: FCM is strictly a secure notification delivery transport.
 * Detection happens locally on-device or via the backend FastAPI/Supabase engine.
 */
class FirebaseMessagingService : com.google.firebase.messaging.FirebaseMessagingService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var secureStorage: SecureStorage

    override fun onCreate() {
        super.onCreate()
        secureStorage = SecureStorage(applicationContext)
        NotificationChannelManager.createAllChannels(applicationContext)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.i(TAG, "New FCM Device Registration Token generated")
        secureStorage.saveFcmToken(token)

        // Asynchronously sync device token to Supabase backend
        serviceScope.launch {
            syncDeviceTokenToBackend(token)
        }
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.i(TAG, "FCM message received from: ${remoteMessage.from}")

        val data = remoteMessage.data
        val notification = remoteMessage.notification

        // Identify message category
        val payloadType = (data["type"] ?: data["category"] ?: "threat_alert").lowercase()

        when (payloadType) {
            "threat_alert", "critical_threat", "threat" -> {
                handleThreatAlert(data, notification)
            }
            "security_notification", "security", "scan_complete" -> {
                handleSecurityNotification(data, notification)
            }
            "account_security", "account_event", "auth" -> {
                handleAccountSecurityEvent(data, notification)
            }
            else -> {
                // Default fallback if notification has basic alert
                handleThreatAlert(data, notification)
            }
        }
    }

    private fun handleThreatAlert(data: Map<String, String>, notification: RemoteMessage.Notification?) {
        val title = data["title"] ?: notification?.title ?: "Critical Threat Alert"
        val threatId = data["threat_id"] ?: ("threat-" + UUID.randomUUID().toString().take(6))
        val source = data["source"] ?: "Cloud Threat Detection Engine"
        val category = data["threat_type"] ?: data["category"] ?: "MALICIOUS_COMMUNICATION"
        val riskScore = data["risk_score"]?.toIntOrNull() ?: 85
        val xaiSummary = data["xai_summary"]
            ?: data["explanation"]
            ?: notification?.body
            ?: "Malicious intent and forensic markers identified by backend explainable AI detection."

        val severityStr = data["severity"] ?: if (riskScore >= 80) "CRITICAL" else "HIGH"
        val severity = when (severityStr.uppercase()) {
            "CRITICAL" -> RiskSeverity.CRITICAL
            "HIGH" -> RiskSeverity.HIGH
            "MEDIUM" -> RiskSeverity.MEDIUM
            else -> RiskSeverity.LOW
        }

        // Check if sender/source is already blocked by user
        if (secureStorage.isSourceBlocked(source)) {
            Log.d(TAG, "Threat from blocked source $source intercepted and suppressed.")
        }

        // Register in centralized ThreatStorage for interactive in-app XAI review
        ThreatStorage.addThreat(
            title = title,
            category = category,
            source = source,
            severity = severity,
            riskScore = riskScore,
            xaiSummary = xaiSummary
        )

        // Dispatch actionable notification: VIEW THREAT, MARK SAFE, BLOCK
        ThreatNotificationManager.showThreatNotification(
            context = applicationContext,
            threatId = threatId,
            title = title,
            source = source,
            threatType = category,
            riskScore = riskScore,
            xaiExplanation = xaiSummary,
            severity = severity
        )
    }

    private fun handleSecurityNotification(
        data: Map<String, String>,
        notification: RemoteMessage.Notification?
    ) {
        val title = data["title"] ?: notification?.title ?: "Security Update"
        val body = data["body"] ?: data["message"] ?: notification?.body ?: "Your device protection status is active."
        val notifId = data["id"]?.toIntOrNull() ?: (System.currentTimeMillis() % 100000).toInt()

        ThreatNotificationManager.showSecurityNotification(
            context = applicationContext,
            id = notifId,
            title = title,
            message = body
        )
    }

    private fun handleAccountSecurityEvent(
        data: Map<String, String>,
        notification: RemoteMessage.Notification?
    ) {
        val title = data["title"] ?: notification?.title ?: "Account Security Alert"
        val body = data["body"] ?: data["message"] ?: notification?.body ?: "New security activity detected on your CyberGuard profile."
        val eventType = data["event_type"] ?: "SECURITY_EVENT"
        val notifId = data["id"]?.toIntOrNull() ?: (System.currentTimeMillis() % 100000).toInt()

        ThreatNotificationManager.showAccountSecurityAlert(
            context = applicationContext,
            id = notifId,
            title = title,
            message = body,
            eventType = eventType
        )
    }

    private suspend fun syncDeviceTokenToBackend(token: String) {
        val userId = secureStorage.getUserId() ?: return
        if (!CyberSupabaseClient.isConfigured()) return

        try {
            val payload = buildJsonObject {
                put("user_id", userId)
                put("fcm_token", token)
                put("platform", "android")
                put("updated_at", System.currentTimeMillis())
            }
            CyberSupabaseClient.postgrest["user_devices"].upsert(payload)
            Log.i(TAG, "FCM token synced successfully to Supabase")
        } catch (e: Exception) {
            Log.w(TAG, "Device token sync deferred or failed: ${e.message}")
        }
    }

    companion object {
        private const val TAG = "CyberFCMService"
    }
}
