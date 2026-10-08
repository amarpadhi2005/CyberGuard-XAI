package com.cyberguard.xai.presentation.threats

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.cyberguard.xai.core.rules.XaiExplainerFactory
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.data.repository.threats.ThreatStorage
import com.cyberguard.xai.presentation.components.GradientButton
import com.cyberguard.xai.presentation.components.RiskSeverity
import com.cyberguard.xai.presentation.components.XaiExplanationCard

@Composable
fun ThreatDetailsScreen(
    threatId: String,
    onBack: () -> Unit,
    onAskAssistant: () -> Unit,
    onNavigateToThreatDna: () -> Unit = {}
) {
    val threat = remember(threatId) { ThreatStorage.getThreatById(threatId) }
    val title = threat?.title ?: "Typosquatted Credential Harvester"
    val source = threat?.source ?: "com.google.android.apps.messaging"
    val riskScore = threat?.riskScore ?: 96

    val xaiResult = remember(threatId) {
        XaiExplainerFactory.createSimulatedIncident(
            title = title,
            source = source,
            targetEntity = "http://paypa1-account-security.top/login",
            riskScore = riskScore
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // High-Fidelity Explainable AI Result Component
        XaiExplanationCard(
            result = xaiResult,
            isExpandedDefault = true
        )

        Spacer(modifier = Modifier.height(20.dp))

        // Action Buttons
        GradientButton(
            text = "INSPECT THREAT DNA CORRELATION",
            onClick = onNavigateToThreatDna,
            height = 46.dp
        )

        Spacer(modifier = Modifier.height(10.dp))

        GradientButton(
            text = "ASK AI ASSISTANT ABOUT THIS",
            onClick = onAskAssistant,
            height = 46.dp
        )

        Spacer(modifier = Modifier.height(10.dp))

        GradientButton(
            text = "CONFIRM MITIGATION & DISMISS",
            onClick = onBack,
            height = 46.dp,
            gradientColors = listOf(CyberTextMuted, CyberCardBorder)
        )
    }
}
