package com.cyberguard.xai.presentation.home

import androidx.compose.foundation.background
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
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Hub
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.SmartToy
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberGlassBg
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskSafe
import com.cyberguard.xai.presentation.components.CyberCard
import com.cyberguard.xai.presentation.components.RiskSeverity
import com.cyberguard.xai.presentation.components.SecurityScore
import com.cyberguard.xai.presentation.components.ThreatCard
import com.cyberguard.xai.presentation.components.ThreatItemUiModel

@Composable
fun HomeDashboardScreen(
    onNavigateToProtection: () -> Unit,
    onNavigateToUrlScanner: () -> Unit,
    onNavigateToQrScanner: () -> Unit,
    onNavigateToDeepfake: () -> Unit,
    onNavigateToAssistant: () -> Unit,
    onNavigateToHistory: () -> Unit,
    onNavigateToThreatDetails: (String) -> Unit,
    onNavigateToScoreDetails: () -> Unit,
    onNavigateToThreatDna: () -> Unit = {}
) {
    val sampleThreats = listOf(
        ThreatItemUiModel(
            id = "threat-001",
            title = "IRS Impersonation Robocall Spoof",
            category = "CALL_SCAM",
            source = "+1 (800) 555-0199",
            severity = RiskSeverity.HIGH,
            riskScore = 88,
            xaiSummary = "Unverified VoIP routing with 1,240 collective user flags matching automated extortion scripts.",
            timeAgo = "12m ago"
        ),
        ThreatItemUiModel(
            id = "threat-002",
            title = "Typosquatted Credential Harvester",
            category = "SMISHING_SMS",
            source = "com.google.android.apps.messaging",
            severity = RiskSeverity.CRITICAL,
            riskScore = 96,
            xaiSummary = "Typosquatting 'paypa1.top' detected with coercive account lock claims and unencrypted endpoint.",
            timeAgo = "1h ago"
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Main Radial Security Score Widget
        CyberCard(
            modifier = Modifier.fillMaxWidth(),
            onClick = onNavigateToScoreDetails
        ) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                SecurityScore(
                    score = 88,
                    grade = "A",
                    label = "SECURITY SCORE",
                    onClick = onNavigateToScoreDetails
                )

                Spacer(modifier = Modifier.height(16.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(RiskSafe)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "REAL-TIME AUTONOMOUS SHIELD ACTIVE",
                        color = RiskSafe,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Quick Defense Actions
        Text(
            text = "DEFENSE INTERCEPTORS",
            color = CyberTextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.2.sp,
            modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp)
        )

        Spacer(modifier = Modifier.height(10.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            ActionTile(
                title = "Call Shield",
                subtitle = "Active (VoIP filter)",
                icon = Icons.Default.Call,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToProtection
            )
            ActionTile(
                title = "Notif Sniffer",
                subtitle = "Active (SMS/Chat)",
                icon = Icons.Default.NotificationsActive,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToProtection
            )
        }

        Spacer(modifier = Modifier.height(10.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            ActionTile(
                title = "Scan URL",
                subtitle = "Phishing engine",
                icon = Icons.Default.Link,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToUrlScanner
            )
            ActionTile(
                title = "Scan QR",
                subtitle = "Barcode analyzer",
                icon = Icons.Default.CameraAlt,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToQrScanner
            )
        }

        Spacer(modifier = Modifier.height(10.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            ActionTile(
                title = "Deepfake AI",
                subtitle = "Voice/Face artifacts",
                icon = Icons.Default.GraphicEq,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToDeepfake
            )
            ActionTile(
                title = "AI Copilot",
                subtitle = "Ask cybersecurity bot",
                icon = Icons.Default.SmartToy,
                modifier = Modifier.weight(1f),
                onClick = onNavigateToAssistant
            )
        }

        Spacer(modifier = Modifier.height(18.dp))

        // Threat DNA Multi-Vector Correlation Banner
        CyberCard(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onNavigateToThreatDna() },
            borderColor = RiskCritical.copy(alpha = 0.6f)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Hub,
                            contentDescription = null,
                            tint = CyberCyan,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "THREAT DNA CORRELATION",
                            color = CyberCyan,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.ExtraBold,
                            letterSpacing = 0.5.sp
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Active multi-vector campaign (Call + SMS + URL + QR) detected.",
                        color = CyberText,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Possible related activity • Escalated risk: 96/100",
                        color = RiskCritical,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                Icon(
                    imageVector = Icons.Default.ArrowForward,
                    contentDescription = null,
                    tint = CyberCyan,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Recent Threat Telemetry
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "RECENT THREAT INCIDENTS",
                color = CyberTextMuted,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.2.sp
            )

            Text(
                text = "VIEW ALL",
                color = CyberCyan,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable { onNavigateToHistory() }
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        sampleThreats.forEach { threat ->
            ThreatCard(
                threat = threat,
                onClick = { onNavigateToThreatDetails(threat.id) },
                modifier = Modifier.padding(bottom = 12.dp)
            )
        }
    }
}

@Composable
private fun ActionTile(
    title: String,
    subtitle: String,
    icon: ImageVector,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    CyberCard(
        modifier = modifier,
        onClick = onClick
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(36.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(CyberGlassBg)
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = CyberCyan,
                    modifier = Modifier.size(20.dp)
                )
            }
            Spacer(modifier = Modifier.width(10.dp))
            Column {
                Text(
                    text = title,
                    color = CyberText,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = subtitle,
                    color = CyberTextMuted,
                    fontSize = 10.sp
                )
            }
        }
    }
}
