package com.cyberguard.xai.presentation.protection

import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.app.NotificationManagerCompat
import com.cyberguard.xai.core.rules.NotificationRuleEngine
import com.cyberguard.xai.core.security.PiiSanitizer
import com.cyberguard.xai.core.security.SecureStorage
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.data.repository.threats.ThreatStorage
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.EmptyState
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.RiskBadge
import com.cyberguard.xai.services.notification.CyberNotificationDispatcher

@Composable
fun NotificationProtectionScreen(
    onBack: () -> Unit,
    onNavigateToThreatDetails: ((String) -> Unit)? = null
) {
    val context = LocalContext.current
    val secureStorage = remember { SecureStorage(context) }
    var isEnabled by remember { mutableStateOf(secureStorage.isProtectionActive()) }
    var hasSystemPermission by remember { mutableStateOf(checkNotificationListenerPermission(context)) }
    var showDeleteConfirmDialog by remember { mutableStateOf(false) }

    val threats by ThreatStorage.threats.collectAsState()

    // Periodically re-check system permission
    LaunchedEffect(Unit) {
        hasSystemPermission = checkNotificationListenerPermission(context)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Master Protection Toggle Card
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                            .background(if (isEnabled) CyberCyan.copy(alpha = 0.15f) else CyberGlassBg)
                    ) {
                        Icon(
                            imageVector = Icons.Default.NotificationsActive,
                            contentDescription = null,
                            tint = if (isEnabled) CyberCyan else CyberTextMuted,
                            modifier = Modifier.size(24.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column {
                        Text(
                            text = "Notification Threat Sniffer",
                            color = CyberText,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = if (isEnabled) "Actively inspecting incoming SMS & chat" else "Protection paused by user",
                            color = if (isEnabled) RiskSafe else CyberTextMuted,
                            fontSize = 11.sp
                        )
                    }
                }

                Switch(
                    checked = isEnabled,
                    onCheckedChange = { active ->
                        isEnabled = active
                        secureStorage.setProtectionActive(active)
                    },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = CyberBackground,
                        checkedTrackColor = CyberCyan,
                        uncheckedThumbColor = CyberTextMuted,
                        uncheckedTrackColor = CyberCardBorder
                    )
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // System Permission Access Status & Clear Explanation
        CyberCard(
            modifier = Modifier.fillMaxWidth(),
            borderColor = if (!hasSystemPermission) RiskCritical.copy(alpha = 0.5f) else CyberCardBorder
        ) {
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = if (hasSystemPermission) Icons.Default.CheckCircle else Icons.Default.Warning,
                        contentDescription = null,
                        tint = if (hasSystemPermission) RiskSafe else RiskCritical,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = if (hasSystemPermission) "System Notification Access Granted" else "Notification Access Required",
                        color = if (hasSystemPermission) RiskSafe else RiskCritical,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = "Android requires explicit user authorization via Special App Access to allow CyberGuard to inspect notifications for coercive phishing and smishing scams.",
                    color = CyberTextMuted,
                    fontSize = 11.sp,
                    lineHeight = 16.sp
                )

                if (!hasSystemPermission) {
                    Spacer(modifier = Modifier.height(12.dp))
                    OutlinedButton(
                        onClick = {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                            context.startActivity(intent)
                        },
                        modifier = Modifier.fillMaxWidth().height(42.dp),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Icon(imageVector = Icons.Default.Settings, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = "Grant Notification Access in Settings", color = CyberCyan, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Privacy Guarantee Card
        CyberCard(
            modifier = Modifier.fillMaxWidth(),
            backgroundColor = CyberGlassBg
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Default.Lock, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(22.dp))
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(text = "Zero Cloud Leakage Guarantee", color = CyberCyan, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Text(
                        text = "1. Personal OTPs and account numbers are scrubbed on-device.\n2. Benign notifications are immediately discarded from memory.\n3. You can purge threat logs at any time.",
                        color = CyberTextMuted,
                        fontSize = 10.sp,
                        lineHeight = 15.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Simulated Attack Triggers for Demonstration
        Text(
            text = "TEST RULE ENGINE HEURISTICS (DEMO)",
            color = CyberTextMuted,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            DemoTriggerPill(
                label = "Fake KYC Scam",
                modifier = Modifier.weight(1f),
                onClick = {
                    simulateNotification(
                        context = context,
                        title = "Bank Notice: Urgent KYC",
                        text = "Your PAN card is blocked. Complete KYC verification immediately at http://secure-kyc-update.xyz or services will be terminated."
                    )
                }
            )

            DemoTriggerPill(
                label = "OTP Theft Scam",
                modifier = Modifier.weight(1f),
                onClick = {
                    simulateNotification(
                        context = context,
                        title = "Customer Support",
                        text = "Please share your 6-digit OTP verification code with support to prevent unauthorized login."
                    )
                }
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            DemoTriggerPill(
                label = "Reward / Lottery",
                modifier = Modifier.weight(1f),
                onClick = {
                    simulateNotification(
                        context = context,
                        title = "Mega Cash Rewards",
                        text = "Congratulations! You won $5,000 in our selected winner draw. Claim prize at http://claim-free-bonus.top"
                    )
                }
            )

            DemoTriggerPill(
                label = "IRS Extortion",
                modifier = Modifier.weight(1f),
                onClick = {
                    simulateNotification(
                        context = context,
                        title = "Federal Tax Bureau",
                        text = "Arrest warrant issued for unpaid taxes. Wire transfer $500 immediately to avoid detention."
                    )
                }
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Intercepted Threat Log Header with Delete History Option
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "INTERCEPTED NOTIFICATION THREATS (${threats.size})",
                color = CyberTextMuted,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )

            if (threats.isNotEmpty()) {
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .clickable { showDeleteConfirmDialog = true }
                        .padding(horizontal = 6.dp, vertical = 2.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(imageVector = Icons.Default.Delete, contentDescription = "Clear", tint = RiskCritical, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(text = "CLEAR HISTORY", color = RiskCritical, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        if (threats.isEmpty()) {
            EmptyState(
                title = "No Intercepted Threats",
                description = "Your notification stream is clean. Incoming messages are filtered in real-time."
            )
        } else {
            threats.forEach { item ->
                CyberCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 10.dp),
                    borderColor = item.severity.color.copy(alpha = 0.4f),
                    onClick = {
                        onNavigateToThreatDetails?.invoke(item.id)
                    }
                ) {
                    Column {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(text = item.title, color = CyberText, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                            RiskBadge(severity = item.severity)
                        }

                        Spacer(modifier = Modifier.height(4.dp))
                        Text(text = "Source: ${item.source} • ${item.timeAgo}", color = CyberTextMuted, fontSize = 11.sp)

                        Spacer(modifier = Modifier.height(6.dp))
                        Text(text = item.xaiSummary, color = CyberTextMuted, fontSize = 11.sp, lineHeight = 15.sp)

                        Spacer(modifier = Modifier.height(8.dp))
                        Text(text = "Tap to inspect XAI forensic details →", color = CyberCyan, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    if (showDeleteConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirmDialog = false },
            title = { Text(text = "Purge Threat History?", color = CyberText, fontWeight = FontWeight.Bold) },
            text = {
                Text(
                    text = "This will permanently remove all intercepted notification threats and audit logs from device storage.",
                    color = CyberTextMuted,
                    fontSize = 13.sp
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        ThreatStorage.deleteAllThreats()
                        showDeleteConfirmDialog = false
                    }
                ) {
                    Text(text = "PURGE ALL", color = RiskCritical, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirmDialog = false }) {
                    Text(text = "CANCEL", color = CyberText)
                }
            },
            containerColor = CyberCard,
            shape = RoundedCornerShape(16.dp)
        )
    }
}

@Composable
private fun DemoTriggerPill(
    label: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(10.dp))
            .background(CyberCard)
            .border(1.dp, CyberCardBorder, RoundedCornerShape(10.dp))
            .clickable { onClick() }
            .padding(vertical = 8.dp, horizontal = 10.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = Icons.Default.PlayArrow, contentDescription = null, tint = CyberPink, modifier = Modifier.size(14.dp))
            Spacer(modifier = Modifier.width(4.dp))
            Text(text = label, color = CyberText, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
        }
    }
}

private fun simulateNotification(context: Context, title: String, text: String) {
    val sanitizedTitle = PiiSanitizer.sanitizeText(title)
    val sanitizedText = PiiSanitizer.sanitizeText(text)
    val verdict = NotificationRuleEngine.evaluate(sanitizedTitle, sanitizedText)

    if (verdict.isThreat) {
        val threatId = ThreatStorage.addThreat(
            title = sanitizedTitle,
            category = verdict.primaryThreatType,
            source = "Messages (SMS Simulator)",
            severity = verdict.severity,
            riskScore = verdict.riskScore,
            xaiSummary = verdict.xaiExplanation
        )

        CyberNotificationDispatcher.showThreatWarning(
            context = context,
            threatId = threatId,
            title = sanitizedTitle,
            source = "Messages (SMS Simulator)",
            threatType = verdict.primaryThreatType,
            riskScore = verdict.riskScore
        )
    }
}

private fun checkNotificationListenerPermission(context: Context): Boolean {
    val enabledPackages = NotificationManagerCompat.getEnabledListenerPackages(context)
    return enabledPackages.contains(context.packageName)
}
