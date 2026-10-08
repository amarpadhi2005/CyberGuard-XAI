package com.cyberguard.xai.services.notification

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.cyberguard.xai.presentation.MainActivity
import com.cyberguard.xai.presentation.components.RiskSeverity

/**
 * Manages dispatching structured notifications with actionable quick responses:
 * - VIEW THREAT: Deep-links directly to threat inspection and XAI breakdown in MainActivity.
 * - MARK SAFE: Immediate false-positive dismissal and model adjustment.
 * - BLOCK: Immediate caller/sender blacklist enforcement and alert dismissal.
 */
object ThreatNotificationManager {

    private const val TAG = "ThreatNotificationMgr"

    fun showThreatNotification(
        context: Context,
        threatId: String,
        title: String,
        source: String,
        threatType: String,
        riskScore: Int,
        xaiExplanation: String,
        severity: RiskSeverity = RiskSeverity.HIGH
    ) {
        NotificationChannelManager.createAllChannels(context)

        val notificationId = threatId.hashCode()

        // 1. Action: VIEW THREAT (Deep-links directly to Threat Details screen)
        val viewIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            action = "com.cyberguard.xai.action.VIEW_THREAT"
            putExtra("OPEN_THREAT_ID", threatId)
        }
        val viewPendingIntent = PendingIntent.getActivity(
            context,
            notificationId + 1,
            viewIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // 2. Action: MARK SAFE (Direct background receiver dismissal)
        val markSafeIntent = Intent(context, ThreatNotificationActionReceiver::class.java).apply {
            action = ThreatNotificationActionReceiver.ACTION_MARK_SAFE
            putExtra(ThreatNotificationActionReceiver.EXTRA_THREAT_ID, threatId)
            putExtra(ThreatNotificationActionReceiver.EXTRA_NOTIFICATION_ID, notificationId)
        }
        val markSafePendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 2,
            markSafeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // 3. Action: BLOCK (Direct background receiver sender blocking)
        val blockIntent = Intent(context, ThreatNotificationActionReceiver::class.java).apply {
            action = ThreatNotificationActionReceiver.ACTION_BLOCK
            putExtra(ThreatNotificationActionReceiver.EXTRA_THREAT_ID, threatId)
            putExtra(ThreatNotificationActionReceiver.EXTRA_SOURCE, source)
            putExtra(ThreatNotificationActionReceiver.EXTRA_NOTIFICATION_ID, notificationId)
        }
        val blockPendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 3,
            blockIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val bigText = buildString {
            append("⚠️ [$threatType] detected from $source\n")
            append("Risk Score: $riskScore/100 • Severity: ${severity.name}\n\n")
            append("XAI Findings: $xaiExplanation\n\n")
            append("Choose an immediate defense action below:")
        }

        val notification = NotificationCompat.Builder(
            context,
            NotificationChannelManager.CHANNEL_CRITICAL_THREATS
        )
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle("🚨 CyberGuard Threat Alert: $title")
            .setContentText("Risk $riskScore/100 • $threatType from $source")
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(viewPendingIntent)
            // Three required notification actions:
            .addAction(android.R.drawable.ic_menu_view, "VIEW THREAT", viewPendingIntent)
            .addAction(android.R.drawable.checkbox_on_background, "MARK SAFE", markSafePendingIntent)
            .addAction(android.R.drawable.ic_delete, "BLOCK", blockPendingIntent)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
        } catch (se: SecurityException) {
            Log.w(TAG, "Missing POST_NOTIFICATIONS permission on Android 13+: ${se.message}")
        }
    }

    fun showSecurityNotification(
        context: Context,
        id: Int,
        title: String,
        message: String
    ) {
        NotificationChannelManager.createAllChannels(context)

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(
            context,
            NotificationChannelManager.CHANNEL_SECURITY_NOTIFICATIONS
        )
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("🛡️ $title")
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(id, notification)
        } catch (_: SecurityException) {
        }
    }

    fun showAccountSecurityAlert(
        context: Context,
        id: Int,
        title: String,
        message: String,
        eventType: String = "ACCOUNT_EVENT"
    ) {
        NotificationChannelManager.createAllChannels(context)

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(
            context,
            NotificationChannelManager.CHANNEL_ACCOUNT_SECURITY
        )
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentTitle("🔐 $title")
            .setContentText(message)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("Event: $eventType\n\n$message\n\nIf you did not initiate this action, review your CyberGuard Security Center immediately.")
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(id, notification)
        } catch (_: SecurityException) {
        }
    }

    fun cancelNotification(context: Context, notificationId: Int) {
        try {
            NotificationManagerCompat.from(context).cancel(notificationId)
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling notification: ${e.message}")
        }
    }
}
