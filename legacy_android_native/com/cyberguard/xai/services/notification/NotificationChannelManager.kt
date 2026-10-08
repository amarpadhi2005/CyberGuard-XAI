package com.cyberguard.xai.services.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build

/**
 * Manages notification channels for CyberGuard XAI.
 * Channels are categorized into:
 * 1. Critical Threat Alerts (High priority, vibration, red light)
 * 2. Security Notifications (Default priority, scans and intelligence)
 * 3. Account Security Events (High priority, amber light, login & credential alerts)
 */
object NotificationChannelManager {

    const val CHANNEL_CRITICAL_THREATS = "cyberguard_critical_threats"
    const val CHANNEL_SECURITY_NOTIFICATIONS = "cyberguard_security_notifications"
    const val CHANNEL_ACCOUNT_SECURITY = "cyberguard_account_security"
    const val CHANNEL_LEGACY_ALERTS = "cyberguard_threat_alerts"

    fun createAllChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            ?: return

        // 1. Critical Threat Alerts Channel
        val criticalChannel = NotificationChannel(
            CHANNEL_CRITICAL_THREATS,
            "Critical Threat Alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "High-priority alarms for intercepted phishing, scam calls, and credential theft"
            enableLights(true)
            lightColor = Color.RED
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 500, 250, 500)
            setShowBadge(true)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }

        // 2. Security Notifications Channel
        val securityChannel = NotificationChannel(
            CHANNEL_SECURITY_NOTIFICATIONS,
            "Security Notifications",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "Updates on threat intelligence digests, background scans, and system protection"
            enableLights(true)
            lightColor = Color.CYAN
            enableVibration(true)
            setShowBadge(true)
        }

        // 3. Account Security Events Channel
        val accountChannel = NotificationChannel(
            CHANNEL_ACCOUNT_SECURITY,
            "Account Security Events",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alerts for new logins, password changes, and account security anomalies"
            enableLights(true)
            lightColor = Color.rgb(255, 165, 0) // Amber/Orange
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 300, 150, 300)
            setShowBadge(true)
        }

        // Legacy channel for backward compatibility
        val legacyChannel = NotificationChannel(
            CHANNEL_LEGACY_ALERTS,
            "CyberGuard Threat Alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Legacy warning notifications channel"
            enableVibration(true)
            enableLights(true)
        }

        notificationManager.createNotificationChannels(
            listOf(criticalChannel, securityChannel, accountChannel, legacyChannel)
        )
    }
}
