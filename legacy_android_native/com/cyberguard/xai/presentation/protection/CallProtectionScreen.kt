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
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.PhoneDisabled
import androidx.compose.material.icons.filled.PhoneInTalk
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.VolumeMute
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
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
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskMedium
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.RiskBadge
import com.cyberguard.xai.presentation.components.RiskSeverity

private data class CallLogEntry(
    val number: String,
    val callerName: String?,
    val action: String,
    val riskScore: Int,
    val severity: RiskSeverity,
    val xaiReason: String,
    val time: String
)

@Composable
fun CallProtectionScreen(
    onBack: () -> Unit
) {
    var screeningEnabled by remember { mutableStateOf(true) }
    var autoBlockEnabled by remember { mutableStateOf(true) }
    var blockThreshold by remember { mutableFloatStateOf(75f) }

    val recentCalls = remember {
        listOf(
            CallLogEntry(
                number = "+1 (800) 555-0199",
                callerName = "Tax Relief Direct",
                action = "BLOCKED",
                riskScore = 88,
                severity = RiskSeverity.HIGH,
                xaiReason = "VoIP spoofer fingerprint matching high-burst robocall pool.",
                time = "Today, 1:14 PM"
            ),
            CallLogEntry(
                number = "+1 (415) 555-9201",
                callerName = "Solar Warranty Group",
                action = "SILENCED",
                riskScore = 65,
                severity = RiskSeverity.MEDIUM,
                xaiReason = "Cold caller with telemarketing pattern; muted ringtone automatically.",
                time = "Yesterday, 4:30 PM"
            ),
            CallLogEntry(
                number = "+1 (212) 555-4321",
                callerName = "Downtown Medical Clinic",
                action = "ALLOWED",
                riskScore = 12,
                severity = RiskSeverity.SAFE,
                xaiReason = "Verified Landline with clean registry reputation.",
                time = "Oct 1, 10:00 AM"
            )
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Master Screening Toggle
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = "CallScreeningService Engine", color = CyberText, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(text = "Intercepts incoming calls via Android Telecom subsystem", color = CyberTextMuted, fontSize = 11.sp)
                }
                Switch(
                    checked = screeningEnabled,
                    onCheckedChange = { screeningEnabled = it },
                    colors = SwitchDefaults.colors(checkedThumbColor = CyberBackground, checkedTrackColor = CyberCyan)
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Threshold Configuration
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = "Auto-Block High Risk Calls", color = CyberText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        Text(text = "Disallows connection before phone starts ringing", color = CyberTextMuted, fontSize = 11.sp)
                    }
                    Switch(
                        checked = autoBlockEnabled,
                        onCheckedChange = { autoBlockEnabled = it },
                        colors = SwitchDefaults.colors(checkedThumbColor = CyberBackground, checkedTrackColor = CyberPink)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                Text(
                    text = "Risk Threshold: ${blockThreshold.toInt()}/100",
                    color = CyberCyan,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )

                Slider(
                    value = blockThreshold,
                    onValueChange = { blockThreshold = it },
                    valueRange = 50f..95f,
                    steps = 8,
                    colors = SliderDefaults.colors(
                        thumbColor = CyberCyan,
                        activeTrackColor = CyberCyan,
                        inactiveTrackColor = CyberCardBorder
                    )
                )

                Text(
                    text = "Calls scoring ≥ ${blockThreshold.toInt()} risk points will be automatically terminated.",
                    color = CyberTextMuted,
                    fontSize = 11.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "RECENT CALL SCREENING LOGS",
            color = CyberTextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(12.dp))

        recentCalls.forEach { call ->
            CyberCard(
                modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp),
                borderColor = call.severity.color.copy(alpha = 0.3f)
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(text = call.number, color = CyberText, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                            call.callerName?.let {
                                Text(text = it, color = CyberTextMuted, fontSize = 11.sp)
                            }
                        }

                        RiskBadge(severity = call.severity)
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = "Verdict: ${call.action} (Risk Score: ${call.riskScore})",
                        color = if (call.action == "BLOCKED") RiskCritical else if (call.action == "SILENCED") RiskMedium else RiskSafe,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = "XAI: ${call.xaiReason}",
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        lineHeight = 16.sp
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(text = call.time, color = CyberTextMuted, fontSize = 10.sp)
                }
            }
        }
    }
}
