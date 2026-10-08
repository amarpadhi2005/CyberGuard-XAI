package com.cyberguard.xai.presentation.protection

import androidx.compose.foundation.background
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
import androidx.compose.material.icons.automirrored.filled.ArrowForwardIos
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.presentation.components.CyberCard

@Composable
fun ProtectionCenterScreen(
    onNavigateToCallProtection: () -> Unit,
    onNavigateToNotificationProtection: () -> Unit
) {
    var globalShieldActive by remember { mutableStateOf(true) }
    var hudOverlayActive by remember { mutableStateOf(true) }
    var clipboardScanActive by remember { mutableStateOf(true) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Master Shield Card
        CyberCard(
            modifier = Modifier.fillMaxWidth(),
            borderColor = if (globalShieldActive) CyberCyan else CyberCardBorder
        ) {
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
                            .size(46.dp)
                            .clip(CircleShape)
                            .background(if (globalShieldActive) RiskSafe.copy(alpha = 0.15f) else CyberGlassBg)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Security,
                            contentDescription = null,
                            tint = if (globalShieldActive) RiskSafe else CyberTextMuted,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = if (globalShieldActive) "CYBER DEFENSE ENGAGED" else "PROTECTION PAUSED",
                            color = if (globalShieldActive) RiskSafe else CyberTextMuted,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 13.sp
                        )
                        Text(
                            text = if (globalShieldActive) "Interceptors actively monitoring" else "Tap switch to enable defense",
                            color = CyberTextMuted,
                            fontSize = 11.sp
                        )
                    }
                }

                Switch(
                    checked = globalShieldActive,
                    onCheckedChange = { globalShieldActive = it },
                    colors = switchColors()
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "SUBSYSTEM INTERCEPTORS",
            color = CyberTextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Call Protection Subsystem Card
        ProtectionModuleCard(
            title = "AI Call Identification & Screening",
            description = "Analyzes incoming numbers, flags VoIP spoofing, auto-silences high-risk robocalls.",
            icon = Icons.Default.Call,
            statusLabel = "Configured (Threshold: 75/100)",
            onClick = onNavigateToCallProtection
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Notification Protection Subsystem Card
        ProtectionModuleCard(
            title = "Notification Threat Sniffer",
            description = "Intercepts SMS and messaging notifications for coercive phishing and bank scams.",
            icon = Icons.Default.NotificationsActive,
            statusLabel = "Active (Scam regex + Cloud NLP)",
            onClick = onNavigateToNotificationProtection
        )

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "HEURISTIC CONTROLS",
            color = CyberTextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(10.dp))

        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = "Realtime Floating HUD", color = CyberText, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text(text = "Renders urgent risk alert overlay during incoming call ring", color = CyberTextMuted, fontSize = 11.sp)
                    }
                    Switch(checked = hudOverlayActive, onCheckedChange = { hudOverlayActive = it }, colors = switchColors())
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = "Auto-Scan Clipboard URLs", color = CyberText, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text(text = "Evaluates copied links instantly for homograph attacks", color = CyberTextMuted, fontSize = 11.sp)
                    }
                    Switch(checked = clipboardScanActive, onCheckedChange = { clipboardScanActive = it }, colors = switchColors())
                }
            }
        }
    }
}

@Composable
private fun ProtectionModuleCard(
    title: String,
    description: String,
    icon: ImageVector,
    statusLabel: String,
    onClick: () -> Unit
) {
    CyberCard(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(42.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(CyberGlassBg)
            ) {
                Icon(imageVector = icon, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(22.dp))
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(text = title, color = CyberText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                Spacer(modifier = Modifier.height(2.dp))
                Text(text = description, color = CyberTextMuted, fontSize = 11.sp, lineHeight = 16.sp)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = statusLabel, color = CyberCyan, fontSize = 10.sp, fontWeight = FontWeight.SemiBold)
            }

            Spacer(modifier = Modifier.width(8.dp))

            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                contentDescription = null,
                tint = CyberTextMuted,
                modifier = Modifier.size(14.dp)
            )
        }
    }
}

@Composable
private fun switchColors() = SwitchDefaults.colors(
    checkedThumbColor = CyberBackground,
    checkedTrackColor = CyberCyan,
    uncheckedThumbColor = CyberTextMuted,
    uncheckedTrackColor = CyberCardBorder
)
