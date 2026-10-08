package com.cyberguard.xai

import com.cyberguard.xai.data.repository.threats.ThreatDnaRepository
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ThreatDnaRepositoryTest {

    @Test
    fun testThreatDnaCampaign_initialization_correlatesMultiVectorEvents() {
        val campaign = ThreatDnaRepository.activeCampaign.value
        assertNotNull(campaign)
        campaign!!

        // Campaign ID and fingerprint format
        assertTrue(campaign.campaignId.startsWith("DNA-CMP-"))
        assertTrue(campaign.dnaFingerprint.startsWith("DNA:"))

        // Strict phrasing requirement: "Possible Related Activity"
        assertEquals("Possible Related Activity", campaign.correlationStatus)
        assertTrue(campaign.disclaimer.contains("possible related activity"))

        // Multi-vector attack chain: call + notification + URL + QR payment
        assertEquals(4, campaign.eventCount)
        assertTrue(campaign.vectorsInvolved.any { it.contains("Call", ignoreCase = true) })
        assertTrue(campaign.vectorsInvolved.any { it.contains("Notification", ignoreCase = true) || it.contains("SMS", ignoreCase = true) })
        assertTrue(campaign.vectorsInvolved.any { it.contains("URL", ignoreCase = true) })
        assertTrue(campaign.vectorsInvolved.any { it.contains("QR", ignoreCase = true) || it.contains("Payment", ignoreCase = true) })

        // Risk escalation: Multi-vector convergence elevates risk
        assertTrue(campaign.escalatedRiskScore > campaign.baselineRiskScore)
        assertTrue(campaign.escalationDelta > 0)
        assertTrue(campaign.escalatedRiskScore >= 90)

        // Chronological timeline progression
        val timeline = campaign.timeline
        assertEquals(4, timeline.size)
        assertEquals(1, timeline[0].stepNumber)
        assertEquals("T+00m", timeline[0].elapsedTime)
        assertEquals(4, timeline[3].stepNumber)

        // Actionable defense playbook
        assertTrue(campaign.recommendedActionPlaybook.isNotEmpty())
    }

    @Test
    fun testThreatDnaTimeWindow_configurableFiltering() {
        ThreatDnaRepository.setTimeWindow(6)
        assertEquals(6, ThreatDnaRepository.selectedTimeWindowHours.value)
        assertNotNull(ThreatDnaRepository.activeCampaign.value)

        ThreatDnaRepository.setTimeWindow(24)
        assertEquals(24, ThreatDnaRepository.selectedTimeWindowHours.value)
    }
}
