package com.cyberguard.xai.data.repository.threats

import com.cyberguard.xai.presentation.components.RiskSeverity
import com.cyberguard.xai.presentation.components.ThreatItemUiModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.util.UUID

object ThreatStorage {

    private val _threats = MutableStateFlow<List<ThreatItemUiModel>>(
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
            )
        )
    )

    val threats: StateFlow<List<ThreatItemUiModel>> = _threats.asStateFlow()

    fun addThreat(
        title: String,
        category: String,
        source: String,
        severity: RiskSeverity,
        riskScore: Int,
        xaiSummary: String
    ): String {
        val id = "threat-${UUID.randomUUID().toString().take(6)}"
        val newThreat = ThreatItemUiModel(
            id = id,
            title = title,
            category = category,
            source = source,
            severity = severity,
            riskScore = riskScore,
            xaiSummary = xaiSummary,
            timeAgo = "Just now"
        )

        _threats.update { current ->
            listOf(newThreat) + current
        }
        return id
    }

    fun getThreatById(id: String): ThreatItemUiModel? {
        return _threats.value.find { it.id == id }
    }

    fun deleteThreat(id: String) {
        _threats.update { current ->
            current.filterNot { it.id == id }
        }
    }

    fun deleteAllThreats() {
        _threats.value = emptyList()
    }
}
