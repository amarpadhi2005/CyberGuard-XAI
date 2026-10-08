package com.cyberguard.xai.presentation.threats

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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.presentation.components.EmptyState
import com.cyberguard.xai.presentation.components.RiskSeverity
import com.cyberguard.xai.presentation.components.ThreatCard
import com.cyberguard.xai.presentation.components.ThreatItemUiModel

@Composable
fun ThreatHistoryScreen(
    onNavigateToDetails: (String) -> Unit
) {
    var selectedFilter by remember { mutableStateOf("ALL") }

    val allThreats = remember {
        listOf(
            ThreatItemUiModel(
                id = "threat-001",
                title = "IRS Impersonation Robocall Spoof",
                category = "CALL_SCAM",
                source = "+1 (800) 555-0199",
                severity = RiskSeverity.HIGH,
                riskScore = 88,
                xaiSummary = "Unverified VoIP carrier with 1,240 collective user flags matching automated extortion scripts.",
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
            ),
            ThreatItemUiModel(
                id = "threat-003",
                title = "High-Risk Crypto Drainer QR Code",
                category = "QR_SCAM",
                source = "CameraX Scanner",
                severity = RiskSeverity.CRITICAL,
                riskScore = 93,
                xaiSummary = "Obfuscated redirect pointing to malicious decentralized contract drainer.",
                timeAgo = "3h ago"
            ),
            ThreatItemUiModel(
                id = "threat-004",
                title = "Synthetic Neural Voice Clone",
                category = "DEEPFAKE_AUDIO",
                source = "voice_sample_emergency.wav",
                severity = RiskSeverity.HIGH,
                riskScore = 89,
                xaiSummary = "Acoustic phase consistency anomaly above 4kHz with complete absence of natural micro-tremors.",
                timeAgo = "1d ago"
            ),
            ThreatItemUiModel(
                id = "threat-005",
                title = "Unsolicited Cold Warranty Caller",
                category = "ROBOCALL",
                source = "+1 (415) 555-9201",
                severity = RiskSeverity.MEDIUM,
                riskScore = 65,
                xaiSummary = "Automated high-frequency outbound spam pattern; automatically silenced.",
                timeAgo = "2d ago"
            )
        )
    }

    val filteredThreats = when (selectedFilter) {
        "CRITICAL" -> allThreats.filter { it.severity == RiskSeverity.CRITICAL }
        "HIGH" -> allThreats.filter { it.severity == RiskSeverity.HIGH }
        "MEDIUM" -> allThreats.filter { it.severity == RiskSeverity.MEDIUM }
        else -> allThreats
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .padding(16.dp)
    ) {
        // Filter Chips Row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            listOf("ALL", "CRITICAL", "HIGH", "MEDIUM").forEach { filter ->
                val isSelected = selectedFilter == filter
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (isSelected) CyberCyan.copy(alpha = 0.2f) else CyberCard)
                        .border(1.dp, if (isSelected) CyberCyan else CyberCardBorder, RoundedCornerShape(12.dp))
                        .clickable { selectedFilter = filter }
                        .padding(horizontal = 14.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = filter,
                        color = if (isSelected) CyberCyan else CyberTextMuted,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        if (filteredThreats.isEmpty()) {
            EmptyState(
                title = "No Threats Found",
                description = "No logged security events match the selected severity filter."
            )
        } else {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                items(filteredThreats) { threat ->
                    ThreatCard(
                        threat = threat,
                        onClick = { onNavigateToDetails(threat.id) }
                    )
                }
            }
        }
    }
}
