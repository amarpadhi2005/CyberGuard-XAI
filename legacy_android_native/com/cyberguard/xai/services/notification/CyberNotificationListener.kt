package com.cyberguard.xai.services.notification

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.cyberguard.xai.core.network.CyberSupabaseClient
import com.cyberguard.xai.core.rules.NotificationRuleEngine
import com.cyberguard.xai.core.security.PiiSanitizer
import com.cyberguard.xai.core.security.SecureStorage
import com.cyberguard.xai.data.repository.threats.ThreatStorage
import io.github.jan.supabase.postgrest.postgrest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

class CyberNotificationListener : NotificationListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var secureStorage: SecureStorage

    override fun onCreate() {
        super.onCreate()
        secureStorage = SecureStorage(applicationContext)
        CyberNotificationDispatcher.createNotificationChannel(applicationContext)
        Log.i(TAG, "CyberNotificationListener service initialized")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        // 1. Check user authorization & master switch
        if (!secureStorage.isProtectionActive()) {
            return
        }

        val packageName = sbn.packageName ?: return

        // 2. Ignore self & system loop notifications
        if (packageName == applicationContext.packageName ||
            packageName == "android" ||
            packageName == "com.android.systemui" ||
            packageName.contains("dialer")
        ) {
            return
        }

        val extras = sbn.notification.extras ?: return
        val rawTitle = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val rawText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()

        if (rawTitle.isBlank() && rawText.isBlank()) {
            return
        }

        // 3. Privacy-First: Extract ONLY necessary text and redact PII/OTPs on-device
        val sanitizedTitle = PiiSanitizer.sanitizeText(rawTitle, maxLength = 80)
        val sanitizedSnippet = PiiSanitizer.sanitizeText(rawText, maxLength = 220)

        // 4. Send to Local Lightweight Rule Engine First
        val verdict = NotificationRuleEngine.evaluate(sanitizedTitle, sanitizedSnippet)

        // 5. If rule engine detects threat, dispatch alert and store event
        if (verdict.isThreat) {
            Log.w(TAG, "🚨 Intercepted threat from $packageName! Score: ${verdict.riskScore}")

            // Add to centralized reactive Threat Storage
            val threatId = ThreatStorage.addThreat(
                title = if (sanitizedTitle.isNotBlank()) sanitizedTitle else "Scam Message Intercepted",
                category = verdict.primaryThreatType,
                source = resolveAppName(packageName),
                severity = verdict.severity,
                riskScore = verdict.riskScore,
                xaiSummary = verdict.xaiExplanation
            )

            // Dispatch Warning Notification to User
            CyberNotificationDispatcher.showThreatWarning(
                context = applicationContext,
                threatId = threatId,
                title = sanitizedTitle.ifBlank { "Suspicious Communication" },
                source = resolveAppName(packageName),
                threatType = verdict.primaryThreatType,
                riskScore = verdict.riskScore
            )

            // 6. Asynchronously log security event & sync with Supabase backend
            serviceScope.launch {
                syncSecurityEventToBackend(
                    packageName = packageName,
                    threatType = verdict.primaryThreatType,
                    riskScore = verdict.riskScore,
                    explanation = verdict.xaiExplanation
                )
            }
        }
    }

    private suspend fun syncSecurityEventToBackend(
        packageName: String,
        threatType: String,
        riskScore: Int,
        explanation: String
    ) {
        val userId = secureStorage.getUserId() ?: return
        if (!CyberSupabaseClient.isConfigured()) return

        try {
            val eventPayload = buildJsonObject {
                put("user_id", userId)
                put("event_type", "NOTIFICATION_INTERCEPTED")
                put("event_severity", if (riskScore >= 75) "CRITICAL" else "WARNING")
                put("title", "Threat intercepted from $packageName")
                put("details", buildJsonObject {
                    put("threat_type", threatType)
                    put("risk_score", riskScore)
                    put("xai_explanation", explanation)
                })
            }
            CyberSupabaseClient.postgrest["security_events"].insert(eventPayload)
        } catch (e: Exception) {
            Log.e(TAG, "Failed syncing threat event to cloud: ${e.message}")
        }
    }

    private fun resolveAppName(packageName: String): String {
        return when {
            packageName.contains("messaging") || packageName.contains("sms") -> "Messages (SMS)"
            packageName.contains("whatsapp") -> "WhatsApp"
            packageName.contains("telegram") -> "Telegram"
            packageName.contains("gmail") || packageName.contains("mail") -> "Email Client"
            else -> packageName
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i(TAG, "CyberNotificationListener destroyed")
    }

    companion object {
        private const val TAG = "CyberNotificationListener"
    }
}
