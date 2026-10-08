package com.cyberguard.xai.services.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationManagerCompat
import com.cyberguard.xai.core.network.CyberSupabaseClient
import com.cyberguard.xai.core.security.SecureStorage
import com.cyberguard.xai.data.repository.threats.ThreatStorage
import io.github.jan.supabase.postgrest.postgrest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

/**
 * Handles instant user actions from threat notifications without requiring app launch:
 * 1. MARK SAFE - Dismisses threat alert, removes it from active threats, records feedback.
 * 2. BLOCK - Blocks the malicious sender/source permanently in SecureStorage and dismisses alert.
 */
class ThreatNotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val threatId = intent.getStringExtra(EXTRA_THREAT_ID).orEmpty()
        val source = intent.getStringExtra(EXTRA_SOURCE).orEmpty()
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, threatId.hashCode())

        // 1. Dismiss notification from Android system tray
        try {
            NotificationManagerCompat.from(context).cancel(notificationId)
        } catch (e: Exception) {
            Log.e(TAG, "Error dismissing notification: ${e.message}")
        }

        val secureStorage = SecureStorage(context)

        when (action) {
            ACTION_MARK_SAFE -> {
                Log.i(TAG, "User marked threat $threatId as safe")
                if (threatId.isNotBlank()) {
                    ThreatStorage.deleteThreat(threatId)
                }
                Toast.makeText(context, "Threat marked as safe", Toast.LENGTH_SHORT).show()

                // Asynchronously sync feedback
                CoroutineScope(Dispatchers.IO).launch {
                    syncFeedbackToBackend(secureStorage, threatId, "MARK_SAFE")
                }
            }

            ACTION_BLOCK -> {
                Log.w(TAG, "User blocked source '$source' for threat $threatId")
                if (source.isNotBlank()) {
                    secureStorage.addBlockedSource(source)
                }
                if (threatId.isNotBlank()) {
                    ThreatStorage.deleteThreat(threatId)
                }
                Toast.makeText(
                    context,
                    if (source.isNotBlank()) "Blocked source: $source" else "Threat source blocked",
                    Toast.LENGTH_SHORT
                ).show()

                // Asynchronously sync block rule
                CoroutineScope(Dispatchers.IO).launch {
                    syncFeedbackToBackend(secureStorage, threatId, "BLOCK_SOURCE", source)
                }
            }
        }
    }

    private suspend fun syncFeedbackToBackend(
        secureStorage: SecureStorage,
        threatId: String,
        actionType: String,
        targetSource: String = ""
    ) {
        val userId = secureStorage.getUserId() ?: return
        if (!CyberSupabaseClient.isConfigured()) return

        try {
            val payload = buildJsonObject {
                put("user_id", userId)
                put("threat_id", threatId)
                put("action", actionType)
                if (targetSource.isNotBlank()) {
                    put("blocked_source", targetSource)
                }
                put("timestamp", System.currentTimeMillis())
            }
            CyberSupabaseClient.postgrest["threat_feedback"].insert(payload)
        } catch (e: Exception) {
            Log.w(TAG, "Feedback sync skipped or failed: ${e.message}")
        }
    }

    companion object {
        const val TAG = "ThreatNotificationAction"
        const val ACTION_MARK_SAFE = "com.cyberguard.xai.action.MARK_SAFE"
        const val ACTION_BLOCK = "com.cyberguard.xai.action.BLOCK"

        const val EXTRA_THREAT_ID = "extra_threat_id"
        const val EXTRA_SOURCE = "extra_source"
        const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
    }
}
