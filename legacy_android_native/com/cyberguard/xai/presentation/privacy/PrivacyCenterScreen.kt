package com.cyberguard.xai.presentation.privacy

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
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
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
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.presentation.components.CyberCard

@Composable
fun PrivacyCenterScreen(
    onNavigateBack: () -> Unit
) {
    var hashPhoneNumbers by remember { mutableStateOf(true) }
    var sanitizeNotifications by remember { mutableStateOf(true) }
    var zeroKnowledgeLogs by remember { mutableStateOf(true) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Top Assurance Banner
        CyberCard(
            modifier = Modifier.fillMaxWidth(),
            backgroundColor = CyberGlassBg
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(CyberCyan.copy(alpha = 0.15f))
                ) {
                    Icon(imageVector = Icons.Default.Shield, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(24.dp))
                }
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(text = "ZERO-KNOWLEDGE PRIVACY MODEL", color = CyberCyan, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Text(
                        text = "Your private contacts, SMS contents, and voice samples never leave device memory unencrypted.",
                        color = CyberTextMuted,
                        fontSize = 11.sp,
                        lineHeight = 15.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "ON-DEVICE PRIVACY POLICIES",
            color = CyberTextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp,
            modifier = Modifier.padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(10.dp))

        // Privacy Controls
        CyberCard(modifier = Modifier.fillMaxWidth()) {
            Column {
                PrivacyToggleRow(
                    title = "Salted Hashing for Phone Numbers",
                    description = "Converts incoming caller numbers into SHA-256 hashes before checking threat intelligence registries.",
                    icon = Icons.Default.Phone,
                    checked = hashPhoneNumbers,
                    onCheckedChange = { hashPhoneNumbers = it }
                )

                Spacer(modifier = Modifier.height(16.dp))

                PrivacyToggleRow(
                    title = "Strip 2FA & OTP Tokens",
                    description = "Removes one-time passcodes and account verification numbers before notification text analysis.",
                    icon = Icons.Default.Lock,
                    checked = sanitizeNotifications,
                    onCheckedChange = { sanitizeNotifications = it }
                )

                Spacer(modifier = Modifier.height(16.dp))

                PrivacyToggleRow(
                    title = "Hardware Keystore Isolation",
                    description = "App session tokens are bound to the Android Keystore with AES256-GCM hardware protection.",
                    icon = Icons.Default.Fingerprint,
                    checked = zeroKnowledgeLogs,
                    onCheckedChange = { zeroKnowledgeLogs = it }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Purge Cache Option
        Button(
            onClick = { /* Clear local cache */ },
            modifier = Modifier.fillMaxWidth().height(48.dp),
            colors = ButtonDefaults.buttonColors(containerColor = CyberBackground),
            border = androidx.compose.foundation.BorderStroke(1.dp, CyberCardBorder),
            shape = androidx.compose.foundation.shape.RoundedCornerShape(12.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Default.DeleteSweep, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "PURGE LOCAL CACHED TELEMETRY", color = CyberText, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun PrivacyToggleRow(
    title: String,
    description: String,
    icon: ImageVector,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = CyberCyan, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.width(10.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, color = CyberText, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(2.dp))
            Text(text = description, color = CyberTextMuted, fontSize = 11.sp, lineHeight = 15.sp)
        }
        Spacer(modifier = Modifier.width(10.dp))
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = CyberBackground,
                checkedTrackColor = CyberCyan,
                uncheckedThumbColor = CyberTextMuted,
                uncheckedTrackColor = CyberCardBorder
            )
        )
    }
}
