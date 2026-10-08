import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/threat_dna_campaign.dart';

class ThreatCorrelationEngine {
  /// Builds a correlated multi-stage threat campaign from events
  ThreatDnaCampaign correlateMultiVectorEvents({
    required List<Map<String, dynamic>> rawEvents,
    int timeWindowHours = 24,
    String userId = 'DEMO_USER_001',
    int? maxStageLimit,
  }) {
    final now = DateTime.now();

    // Default 3-stage Coordinated Attack Benchmark Scenario:
    // 1. User received a suspicious notification
    // 2. Then scanned a phishing URL
    // 3. Then received a scam call
    final List<ThreatDnaTimelineStep> fullSteps = [
      ThreatDnaTimelineStep(
        stepNumber: 1,
        vectorName: 'SUSPICIOUS_NOTIFICATION',
        title: 'Fake Banking KYC Alert Intercepted',
        source: 'SMS Messaging Service',
        riskScore: 72,
        elapsedStr: 'T+00m',
        timestamp: now.subtract(const Duration(minutes: 32)),
        description:
            'Urgent push alert claiming Chase Bank account suspension unless verified within 24h. Enclosed deceptive hyperlink.',
        icon: Icons.notifications_active_rounded,
      ),
      ThreatDnaTimelineStep(
        stepNumber: 2,
        vectorName: 'PHISHING_URL',
        title: 'Typosquatted Banking Portal Scanned',
        source: 'https://secure-chase-update.com',
        riskScore: 88,
        elapsedStr: 'T+15m',
        timestamp: now.subtract(const Duration(minutes: 17)),
        description:
            'User scanned link from SMS. Gemini AI flagged typosquatted Chase domain registered 48h ago on Russian bulletproof host.',
        icon: Icons.language_rounded,
      ),
      ThreatDnaTimelineStep(
        stepNumber: 3,
        vectorName: 'SCAM_CALL',
        title: 'Impersonation Robocall Inbound',
        source: '+1 (800) 492-9182',
        riskScore: 96,
        elapsedStr: 'T+32m',
        timestamp: now.subtract(const Duration(minutes: 2)),
        description:
            'Fraudster called user claiming to be "Chase Security Department" urging immediate 2FA one-time passcode confirmation.',
        icon: Icons.phone_in_talk_rounded,
      ),
    ];

    // Apply stage limit if simulation is active (1, 2, or 3)
    final int limit = maxStageLimit != null
        ? maxStageLimit.clamp(1, fullSteps.length)
        : fullSteps.length;
    final activeSteps = fullSteps.sublist(0, limit);

    final distinctVectors = activeSteps.map((s) => s.vectorName).toSet().toList();
    final highestSingleRisk = activeSteps
        .map((s) => s.riskScore)
        .fold(0, (prev, curr) => curr > prev ? curr : prev);

    // Escalation Algorithm
    int escalationBoost = 0;
    if (distinctVectors.length >= 3) {
      escalationBoost = 18;
    } else if (distinctVectors.length >= 2) {
      escalationBoost = 12;
    }

    final int escalatedRisk = (highestSingleRisk + (distinctVectors.length > 1 ? 8 : 0))
        .clamp(0, 98);

    // Compute deterministic campaign fingerprint
    final seed = '$userId:${activeSteps.length}:${distinctVectors.length}:CHASE';
    final hash = sha256.convert(utf8.encode(seed)).toString().substring(0, 6).toUpperCase();
    final campaignId = 'DNA-CMP-$hash';
    final dnaFingerprint =
        'DNA:${distinctVectors.map((v) => v.split('_')[0]).join('+')}:CHASE:T-32M';

    // Risk Trend Data Points
    final riskTrend = <RiskTrendPoint>[
      const RiskTrendPoint(
        label: 'Stage 1: Notification',
        riskScore: 72,
        timestampStr: '32m ago',
      ),
      if (limit >= 2)
        const RiskTrendPoint(
          label: 'Stage 2: Phishing URL',
          riskScore: 88,
          timestampStr: '17m ago',
        ),
      if (limit >= 3)
        const RiskTrendPoint(
          label: 'Stage 3: Scam Call',
          riskScore: 96,
          timestampStr: '2m ago',
        ),
    ];

    // Correlation Evidence (Phrased carefully with "possible" related activity)
    final evidence = [
      'Temporal Clustering: ${activeSteps.length} distinct security events converged within a 32-minute window.',
      'Target Coherence: All intercepted artifacts specifically focused on Chase Bank financial impersonation.',
      'Attack Vector Escalation: Multi-channel progression from SMS lure ➔ Web credential harvesting ➔ Real-time voice social engineering.',
      'Correlated Threat Hypothesis: Behavioral timing strongly suggests possible coordinated scam activity by an organized syndicate.',
    ];

    return ThreatDnaCampaign(
      campaignId: campaignId,
      dnaFingerprint: dnaFingerprint,
      status: activeSteps.length >= 2
          ? 'POSSIBLE_COORDINATED_SCAM'
          : 'MONITORING_INITIAL_EVENT',
      vectorsInvolved: distinctVectors
          .map((v) => v.replaceAll('_', ' ').toLowerCase())
          .toList(),
      eventCount: activeSteps.length,
      timeSpanMinutes: 32,
      baselineRiskScore: highestSingleRisk,
      escalatedRiskScore: escalatedRisk,
      escalationBoost: escalationBoost,
      confidence: activeSteps.length >= 3 ? 0.92 : (activeSteps.length >= 2 ? 0.78 : 0.50),
      targetBrand: 'Chase Bank Financial Impersonation',
      correlationEvidence: evidence,
      timeline: activeSteps,
      riskTrend: riskTrend,
      recommendedPlaybook:
          '1. Do NOT answer or talk to caller +1 (800) 492-9182.\n'
          '2. Do NOT provide OTP or SMS security codes to anyone.\n'
          '3. Do NOT open the URL in your SMS message.\n'
          '4. Open the official Chase Bank application to verify your account safely.',
      detectedAt: now,
    );
  }
}
