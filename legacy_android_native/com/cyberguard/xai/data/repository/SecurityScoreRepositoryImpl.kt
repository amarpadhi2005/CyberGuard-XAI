package com.cyberguard.xai.data.repository

import com.cyberguard.xai.domain.model.ActionableImprovement
import com.cyberguard.xai.domain.model.FactorCategory
import com.cyberguard.xai.domain.model.FactorStatus
import com.cyberguard.xai.domain.model.PersonalSecurityScore
import com.cyberguard.xai.domain.model.ScoreDeltaEvent
import com.cyberguard.xai.domain.model.ScoreFactor
import com.cyberguard.xai.domain.model.TrainingModule
import com.cyberguard.xai.domain.model.TransparentRule
import com.cyberguard.xai.domain.repository.SecurityScoreRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

class SecurityScoreRepositoryImpl : SecurityScoreRepository {

    private val timeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())

    // Internal posture state
    private var callScreeningActive = true
    private var autoBlockActive = true
    private var notifListenerActive = true
    private var scamSnifferActive = true
    private var biometricActive = true
    private var hudOverlayActive = true
    private var telemetryAnonymized = true
    private var completedTrainingCount = 3
    private var activeCriticalThreats = 0
    private var activeHighThreats = 0
    private var dangerousLinksClicked = 0
    private var clipboardScannerActive = true
    private var scamBlocklistActive = true
    private var blockedCallsCount = 4

    private val _trainingModules = MutableStateFlow(
        listOf(
            TrainingModule(
                id = "mod_1",
                moduleIndex = 1,
                title = "Phishing & Smishing Anatomy",
                description = "Learn how to spot spoofed domains, sender impersonation, and fraudulent bank alerts.",
                pointsReward = 4,
                isCompleted = true,
                quizScorePercent = 100
            ),
            TrainingModule(
                id = "mod_2",
                moduleIndex = 2,
                title = "Voice Clone Deepfake Identification",
                description = "Master audio artifact detection, latency anomalies, and vocal stress cues in AI clones.",
                pointsReward = 4,
                isCompleted = true,
                quizScorePercent = 100
            ),
            TrainingModule(
                id = "mod_3",
                moduleIndex = 3,
                title = "Dangerous Links & Quishing Tactics",
                description = "Examine QR code manipulation, shortened URLs, and deceptive redirect chains.",
                pointsReward = 4,
                isCompleted = true,
                quizScorePercent = 95
            ),
            TrainingModule(
                id = "mod_4",
                moduleIndex = 4,
                title = "Emergency Imposter & OTP Protocol",
                description = "Step-by-step procedures to foil family emergency extortion and one-time password theft.",
                pointsReward = 3,
                isCompleted = false,
                quizScorePercent = null
            )
        )
    )

    private val _scoreHistory = MutableStateFlow(
        mutableListOf(
            ScoreDeltaEvent(
                id = "delta_1",
                timestamp = "Today, 19:30",
                previousScore = 84,
                newScore = 88,
                deltaPoints = 4,
                factorCategory = FactorCategory.USER_TRAINING,
                triggerTitle = "Module 3: Quishing Defense Completed",
                reasonExplanation = "Your score increased by 4 points because you passed the 'Dangerous Links & Quishing Tactics' certification quiz.",
                remediationAction = null
            ),
            ScoreDeltaEvent(
                id = "delta_2",
                timestamp = "Today, 14:15",
                previousScore = 79,
                newScore = 84,
                deltaPoints = 5,
                factorCategory = FactorCategory.CALL_PROTECTION,
                triggerTitle = "Auto-Block High-Risk Calls Engaged",
                reasonExplanation = "Your score increased by 5 points after enabling autonomous blocking of predatory vishing calls.",
                remediationAction = null
            ),
            ScoreDeltaEvent(
                id = "delta_3",
                timestamp = "Yesterday, 22:00",
                previousScore = 87,
                newScore = 79,
                deltaPoints = -8,
                factorCategory = FactorCategory.THREAT_EVENTS,
                triggerTitle = "Critical Phishing SMS Intercepted",
                reasonExplanation = "Your score dropped by 8 points because an incoming message contained an unquarantined malicious banking lure.",
                remediationAction = "Quarantine threat alert (+8 pts)"
            )
        )
    )

    private val _securityScore = MutableStateFlow(computeScore())

    override fun getSecurityScore(): Flow<PersonalSecurityScore> = _securityScore.asStateFlow()

    override fun getScoreHistory(): Flow<List<ScoreDeltaEvent>> = _scoreHistory.asStateFlow()

    override fun getTrainingModules(): Flow<List<TrainingModule>> = _trainingModules.asStateFlow()

    override suspend fun recalculateScore(): Result<PersonalSecurityScore> {
        val previous = _securityScore.value
        val updated = computeScore()
        _securityScore.value = updated

        if (updated.overallScore != previous.overallScore) {
            val delta = updated.overallScore - previous.overallScore
            recordDelta(
                prev = previous.overallScore,
                next = updated.overallScore,
                delta = delta,
                category = FactorCategory.SYSTEM_RECALCULATION,
                title = "Security Posture Recalculated (${if (delta > 0) "+$delta" else "$delta"} pts)",
                explanation = "Your security score was synchronized with your device configuration and telemetry rules.",
                remediation = null
            )
        }
        return Result.success(updated)
    }

    override suspend fun completeTrainingModule(moduleIndex: Int): Result<PersonalSecurityScore> {
        val currentList = _trainingModules.value.toMutableList()
        val targetIdx = currentList.indexOfFirst { it.moduleIndex == moduleIndex }
        if (targetIdx != -1 && !currentList[targetIdx].isCompleted) {
            val module = currentList[targetIdx]
            currentList[targetIdx] = module.copy(isCompleted = true, quizScorePercent = 100)
            _trainingModules.value = currentList
            completedTrainingCount = currentList.count { it.isCompleted }

            val previous = _securityScore.value
            val updated = computeScore()
            _securityScore.value = updated

            val gain = updated.overallScore - previous.overallScore
            recordDelta(
                prev = previous.overallScore,
                next = updated.overallScore,
                delta = gain,
                category = FactorCategory.USER_TRAINING,
                title = "Completed '${module.title}' (+${module.pointsReward} pts)",
                explanation = "Your score increased by ${module.pointsReward} points because you completed training on ${module.title}. Training posture is now at ${(completedTrainingCount * 100) / 4}%.",
                remediation = null
            )
            return Result.success(updated)
        }
        return Result.success(_securityScore.value)
    }

    override suspend fun toggleProtectionSetting(category: FactorCategory, enabled: Boolean): Result<PersonalSecurityScore> {
        val previous = _securityScore.value

        when (category) {
            FactorCategory.CALL_PROTECTION -> {
                callScreeningActive = enabled
                autoBlockActive = enabled
            }
            FactorCategory.NOTIFICATION_PROTECTION -> {
                notifListenerActive = enabled
                scamSnifferActive = enabled
            }
            FactorCategory.SECURITY_SETTINGS -> {
                hudOverlayActive = enabled
                biometricActive = enabled
            }
            FactorCategory.DANGEROUS_LINKS -> {
                clipboardScannerActive = enabled
            }
            FactorCategory.BLOCKED_CALLS -> {
                scamBlocklistActive = enabled
            }
            else -> {}
        }

        val updated = computeScore()
        _securityScore.value = updated
        val delta = updated.overallScore - previous.overallScore

        recordDelta(
            prev = previous.overallScore,
            next = updated.overallScore,
            delta = delta,
            category = category,
            title = if (enabled) "${category.name.replace('_', ' ')} Activated (+${delta} pts)" else "${category.name.replace('_', ' ')} Disabled (${delta} pts)",
            explanation = if (enabled) {
                "Your score increased by $delta points because essential defense interceptors were enabled."
            } else {
                "Your score dropped by ${Math.abs(delta)} points because protection was turned off, exposing your device to threats."
            },
            remediation = if (!enabled) "Re-enable protection in settings (+${Math.abs(delta)} pts)" else null
        )

        return Result.success(updated)
    }

    override suspend fun resolveThreatEvent(threatType: String): Result<PersonalSecurityScore> {
        val previous = _securityScore.value
        val pointsRecovered: Int

        if (threatType == "CRITICAL" && activeCriticalThreats > 0) {
            activeCriticalThreats--
            pointsRecovered = 8
        } else if (threatType == "HIGH" && activeHighThreats > 0) {
            activeHighThreats--
            pointsRecovered = 4
        } else {
            // General threat resolution demo
            pointsRecovered = 8
        }

        val updated = computeScore()
        _securityScore.value = updated

        recordDelta(
            prev = previous.overallScore,
            next = updated.overallScore,
            delta = pointsRecovered,
            category = FactorCategory.THREAT_EVENTS,
            title = "Threat Resolved & Quarantined (+$pointsRecovered pts)",
            explanation = "Your score recovered $pointsRecovered points after neutralizing an active threat event. Active threat exposure reduced to 0.",
            remediation = null
        )

        return Result.success(updated)
    }

    private fun recordDelta(
        prev: Int,
        next: Int,
        delta: Int,
        category: FactorCategory,
        title: String,
        explanation: String,
        remediation: String?
    ) {
        val event = ScoreDeltaEvent(
            id = "delta_${UUID.randomUUID().toString().take(8)}",
            timestamp = "Just now",
            previousScore = prev,
            newScore = next,
            deltaPoints = delta,
            factorCategory = category,
            triggerTitle = title,
            reasonExplanation = explanation,
            remediationAction = remediation
        )
        val currentHistory = _scoreHistory.value.toMutableList()
        currentHistory.add(0, event)
        _scoreHistory.value = currentHistory
    }

    private fun computeScore(): PersonalSecurityScore {
        // 1. Call Protection (15 pts)
        val callRules = listOf(
            TransparentRule(
                ruleId = "R_CALL_SCREEN",
                factorCategory = FactorCategory.CALL_PROTECTION,
                title = "Call Screening Engine",
                description = "Live audio inspection and carrier spam reputation telemetry.",
                pointsAwarded = if (callScreeningActive) 10 else 0,
                maxPoints = 10,
                isSatisfied = callScreeningActive,
                explanation = if (callScreeningActive) "Screening active for unknown callers." else "Call screening is currently inactive.",
                remediationAction = if (!callScreeningActive) "Enable Call Screening (+10 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_CALL_BLOCK",
                factorCategory = FactorCategory.CALL_PROTECTION,
                title = "Auto-Block High-Risk Calls",
                description = "Automatically silences and drops predatory scam telephone numbers.",
                pointsAwarded = if (autoBlockActive) 5 else 0,
                maxPoints = 5,
                isSatisfied = autoBlockActive,
                explanation = if (autoBlockActive) "High-risk scam calls are blocked autonomously." else "Auto-block is disabled.",
                remediationAction = if (!autoBlockActive) "Turn on Auto-Block (+5 pts)" else null
            )
        )
        val callPts = callRules.sumOf { it.pointsAwarded }
        val callFactor = ScoreFactor(
            category = FactorCategory.CALL_PROTECTION,
            name = "Call Protection",
            currentPoints = callPts,
            maxPoints = 15,
            status = if (callPts == 15) FactorStatus.OPTIMAL else if (callPts >= 10) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "Real-time incoming call vetting and automated spoof blocking.",
            rules = callRules
        )

        // 2. Notification Protection (15 pts)
        val notifRules = listOf(
            TransparentRule(
                ruleId = "R_NOTIF_LISTEN",
                factorCategory = FactorCategory.NOTIFICATION_PROTECTION,
                title = "SMS & Notification Listener",
                description = "Intercepts incoming texts and messaging alerts for malware payloads.",
                pointsAwarded = if (notifListenerActive) 10 else 0,
                maxPoints = 10,
                isSatisfied = notifListenerActive,
                explanation = if (notifListenerActive) "Notification stream monitored on-device." else "Notification listener permission disabled.",
                remediationAction = if (!notifListenerActive) "Enable Notification Protection (+10 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_NOTIF_SNIFF",
                factorCategory = FactorCategory.NOTIFICATION_PROTECTION,
                title = "Scam Token NLP Sniffer",
                description = "Identifies fraudulent bank urgency, fake OTPs, and extortion language.",
                pointsAwarded = if (scamSnifferActive) 5 else 0,
                maxPoints = 5,
                isSatisfied = scamSnifferActive,
                explanation = if (scamSnifferActive) "Linguistic fraud sniffer active." else "Urgency heuristics disabled.",
                remediationAction = if (!scamSnifferActive) "Activate Scam Token Sniffer (+5 pts)" else null
            )
        )
        val notifPts = notifRules.sumOf { it.pointsAwarded }
        val notifFactor = ScoreFactor(
            category = FactorCategory.NOTIFICATION_PROTECTION,
            name = "Notification Protection",
            currentPoints = notifPts,
            maxPoints = 15,
            status = if (notifPts == 15) FactorStatus.OPTIMAL else if (notifPts >= 10) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "On-device smishing heuristics and fraud token interception.",
            rules = notifRules
        )

        // 3. Security Settings (15 pts)
        val secRules = listOf(
            TransparentRule(
                ruleId = "R_SEC_BIO",
                factorCategory = FactorCategory.SECURITY_SETTINGS,
                title = "Biometric Screen Enclave",
                description = "Protected by fingerprint, facial unlock, or secure PIN.",
                pointsAwarded = if (biometricActive) 5 else 0,
                maxPoints = 5,
                isSatisfied = biometricActive,
                explanation = if (biometricActive) "Enclave active for key operations." else "Device lock unconfigured.",
                remediationAction = if (!biometricActive) "Configure Biometric Lock (+5 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_SEC_HUD",
                factorCategory = FactorCategory.SECURITY_SETTINGS,
                title = "Floating Warning HUD",
                description = "System overlay alerts you instantly over malicious apps and calls.",
                pointsAwarded = if (hudOverlayActive) 5 else 0,
                maxPoints = 5,
                isSatisfied = hudOverlayActive,
                explanation = if (hudOverlayActive) "Floating threat overlay active." else "Overlay permission missing.",
                remediationAction = if (!hudOverlayActive) "Enable Floating HUD (+5 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_SEC_PRIVACY",
                factorCategory = FactorCategory.SECURITY_SETTINGS,
                title = "Telemetry Hashing & Privacy",
                description = "Salted SHA-256 phone number hashing and zero-knowledge telemetry.",
                pointsAwarded = if (telemetryAnonymized) 5 else 0,
                maxPoints = 5,
                isSatisfied = telemetryAnonymized,
                explanation = if (telemetryAnonymized) "PII anonymization verified." else "Privacy telemetry disabled.",
                remediationAction = if (!telemetryAnonymized) "Enable Telemetry Anonymization (+5 pts)" else null
            )
        )
        val secPts = secRules.sumOf { it.pointsAwarded }
        val secFactor = ScoreFactor(
            category = FactorCategory.SECURITY_SETTINGS,
            name = "Security Settings & Hygiene",
            currentPoints = secPts,
            maxPoints = 15,
            status = if (secPts == 15) FactorStatus.OPTIMAL else if (secPts >= 10) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "Hardened device auth, floating HUD alerts, and privacy protections.",
            rules = secRules
        )

        // 4. User Training (15 pts)
        val trainingWeights = listOf(4, 4, 4, 3)
        val trainingDone = completedTrainingCount.coerceIn(0, 4)
        val trainingPts = trainingWeights.take(trainingDone).sum()
        val trainingTitles = listOf(
            "Phishing & Smishing Anatomy" to 4,
            "Voice Clone Deepfake Identification" to 4,
            "Dangerous Links & Quishing Tactics" to 4,
            "Emergency Imposter & OTP Protocol" to 3
        )
        val trainingRules = trainingTitles.mapIndexed { idx, (title, pts) ->
            val isDone = idx < trainingDone
            TransparentRule(
                ruleId = "R_TRAIN_${idx + 1}",
                factorCategory = FactorCategory.USER_TRAINING,
                title = "Module ${idx + 1}: $title",
                description = "Interactive quiz and defense simulator.",
                pointsAwarded = if (isDone) pts else 0,
                maxPoints = pts,
                isSatisfied = isDone,
                explanation = if (isDone) "Completed (+${pts} pts)." else "Incomplete. Worth +${pts} pts.",
                remediationAction = if (!isDone) "Complete Module ${idx + 1} (+${pts} pts)" else null
            )
        }
        val trainingFactor = ScoreFactor(
            category = FactorCategory.USER_TRAINING,
            name = "User Training Completion",
            currentPoints = trainingPts,
            maxPoints = 15,
            status = if (trainingPts == 15) FactorStatus.OPTIMAL else if (trainingPts >= 8) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "Completed $trainingDone of 4 cyber awareness modules.",
            rules = trainingRules
        )

        // 5. Recent Threat Events (15 pts)
        val threatDeduction = (activeCriticalThreats * 8) + (activeHighThreats * 4)
        val threatPts = (15 - threatDeduction).coerceIn(0, 15)
        val threatRules = listOf(
            TransparentRule(
                ruleId = "R_THREAT_CRIT",
                factorCategory = FactorCategory.THREAT_EVENTS,
                title = "Zero Unresolved Critical Threats",
                description = "No active malware, deepfakes, or credential harvesters.",
                pointsAwarded = if (activeCriticalThreats == 0) 8 else 0,
                maxPoints = 8,
                isSatisfied = activeCriticalThreats == 0,
                explanation = if (activeCriticalThreats == 0) "Zero critical threats detected." else "$activeCriticalThreats active critical threat(s) (-${activeCriticalThreats * 8} pts).",
                remediationAction = if (activeCriticalThreats > 0) "Quarantine Critical Threats (+8 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_THREAT_HIGH",
                factorCategory = FactorCategory.THREAT_EVENTS,
                title = "Zero Unresolved Warning Events",
                description = "No unreviewed high-probability scam messages.",
                pointsAwarded = if (activeHighThreats == 0) 7 else (7 - activeHighThreats * 4).coerceAtLeast(0),
                maxPoints = 7,
                isSatisfied = activeHighThreats == 0,
                explanation = if (activeHighThreats == 0) "No unresolved high warnings." else "$activeHighThreats warning events (-${activeHighThreats * 4} pts).",
                remediationAction = if (activeHighThreats > 0) "Review Threat Events (+4 pts)" else null
            )
        )
        val threatFactor = ScoreFactor(
            category = FactorCategory.THREAT_EVENTS,
            name = "Recent Threat Events",
            currentPoints = threatPts,
            maxPoints = 15,
            status = if (threatPts == 15) FactorStatus.OPTIMAL else if (threatPts >= 8) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = if (threatDeduction == 0) "Clean baseline: Zero unmitigated attacks." else "$threatDeduction pts deducted due to active threats.",
            rules = threatRules
        )

        // 6. Dangerous Links (15 pts)
        val linkCleanPts = if (dangerousLinksClicked == 0) 10 else (10 - dangerousLinksClicked * 5).coerceAtLeast(0)
        val linkScanPts = if (clipboardScannerActive) 5 else 0
        val linkRules = listOf(
            TransparentRule(
                ruleId = "R_LINK_CLEAN",
                factorCategory = FactorCategory.DANGEROUS_LINKS,
                title = "Clean Link History (30 Days)",
                description = "Zero malicious, phishing, or spoofed URLs accessed.",
                pointsAwarded = linkCleanPts,
                maxPoints = 10,
                isSatisfied = dangerousLinksClicked == 0,
                explanation = if (dangerousLinksClicked == 0) "Clean browsing posture verified." else "$dangerousLinksClicked dangerous link(s) accessed.",
                remediationAction = if (dangerousLinksClicked > 0) "Clear browser history and block domains" else null
            ),
            TransparentRule(
                ruleId = "R_LINK_SCAN",
                factorCategory = FactorCategory.DANGEROUS_LINKS,
                title = "Pre-Flight URL Scanner",
                description = "Scans clipboard and tapped URLs before browser execution.",
                pointsAwarded = linkScanPts,
                maxPoints = 5,
                isSatisfied = clipboardScannerActive,
                explanation = if (clipboardScannerActive) "URL pre-flight scanner active." else "Clipboard scanner disabled.",
                remediationAction = if (!clipboardScannerActive) "Turn on URL Pre-Flight Scanner (+5 pts)" else null
            )
        )
        val linkPts = linkCleanPts + linkScanPts
        val linkFactor = ScoreFactor(
            category = FactorCategory.DANGEROUS_LINKS,
            name = "Dangerous Links Posture",
            currentPoints = linkPts,
            maxPoints = 15,
            status = if (linkPts == 15) FactorStatus.OPTIMAL else if (linkPts >= 10) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "Pre-flight link protection and malicious domain interception.",
            rules = linkRules
        )

        // 7. Blocked Calls (10 pts)
        val blockListPts = if (scamBlocklistActive) 5 else 0
        val blockEfficacyPts = if (blockedCallsCount >= 1 || (callScreeningActive && autoBlockActive)) 5 else 2
        val blockRules = listOf(
            TransparentRule(
                ruleId = "R_BLOCK_LIST",
                factorCategory = FactorCategory.BLOCKED_CALLS,
                title = "Scam Blocklist Synchronized",
                description = "Latest cloud-synced database of known predatory callers.",
                pointsAwarded = blockListPts,
                maxPoints = 5,
                isSatisfied = scamBlocklistActive,
                explanation = if (scamBlocklistActive) "Blocklist updated." else "Blocklist out of sync.",
                remediationAction = if (!scamBlocklistActive) "Sync Scam Blocklist (+5 pts)" else null
            ),
            TransparentRule(
                ruleId = "R_BLOCK_EFFICACY",
                factorCategory = FactorCategory.BLOCKED_CALLS,
                title = "Defense Intercept Efficacy",
                description = "Demonstrated ability to intercept incoming vishing attacks.",
                pointsAwarded = blockEfficacyPts,
                maxPoints = 5,
                isSatisfied = blockEfficacyPts == 5,
                explanation = "Verified: $blockedCallsCount robocalls intercepted without user compromise.",
                remediationAction = if (blockEfficacyPts < 5) "Enable auto-block (+3 pts)" else null
            )
        )
        val blockPts = blockListPts + blockEfficacyPts
        val blockFactor = ScoreFactor(
            category = FactorCategory.BLOCKED_CALLS,
            name = "Blocked Calls & Efficacy",
            currentPoints = blockPts,
            maxPoints = 10,
            status = if (blockPts == 10) FactorStatus.OPTIMAL else if (blockPts >= 5) FactorStatus.WARNING else FactorStatus.CRITICAL,
            summary = "$blockedCallsCount scam calls blocked by autonomous firewall.",
            rules = blockRules
        )

        val allFactors = listOf(callFactor, notifFactor, secFactor, trainingFactor, threatFactor, linkFactor, blockFactor)
        val totalScore = allFactors.sumOf { it.currentPoints }.coerceIn(0, 100)

        val (grade, title, desc) = when {
            totalScore >= 95 -> Triple("A+", "Maximum Shield", "All interceptors active, zero unresolved threats, full training certified.")
            totalScore >= 85 -> Triple("A", "High Defense Posture", "Comprehensive protection engaged. Attack surface is tightly minimized.")
            totalScore >= 70 -> Triple("B", "Moderate Defense", "Core defenses operating. Minor configuration gaps or incomplete training.")
            totalScore >= 50 -> Triple("C", "Vulnerable Posture", "Essential interceptors disabled or active threat warnings require attention.")
            totalScore >= 30 -> Triple("D", "High Risk", "Significant vulnerabilities exposed. Malicious links or calls may breach defense.")
            else -> Triple("F", "Critical Hazard", "Crucial security layers inactive. Immediate remediation required.")
        }

        val improvements = mutableListOf<ActionableImprovement>()
        for (f in allFactors) {
            val gap = f.maxPoints - f.currentPoints
            if (gap > 0) {
                improvements.add(
                    ActionableImprovement(
                        factorCategory = f.category,
                        pointsPotential = gap,
                        actionTitle = "Improve ${f.name}",
                        description = "Earn +$gap pts by resolving open rules in ${f.name}."
                    )
                )
            }
        }
        improvements.sortByDescending { it.pointsPotential }

        return PersonalSecurityScore(
            overallScore = totalScore,
            grade = grade,
            postureTitle = title,
            postureDescription = desc,
            factors = allFactors,
            actionableImprovements = improvements,
            recentScoreChanges = _scoreHistory.value.take(5),
            lastCalculatedAt = timeFormat.format(Date())
        )
    }
}
