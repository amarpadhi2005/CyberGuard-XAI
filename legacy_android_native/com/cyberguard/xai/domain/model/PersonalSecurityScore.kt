package com.cyberguard.xai.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class PersonalSecurityScore(
    val overallScore: Int,
    val grade: String,
    val postureTitle: String,
    val postureDescription: String,
    val factors: List<ScoreFactor>,
    val actionableImprovements: List<ActionableImprovement>,
    val recentScoreChanges: List<ScoreDeltaEvent>,
    val lastCalculatedAt: String
)

@Serializable
enum class FactorStatus {
    OPTIMAL,
    WARNING,
    CRITICAL
}

@Serializable
enum class FactorCategory {
    CALL_PROTECTION,
    NOTIFICATION_PROTECTION,
    SECURITY_SETTINGS,
    USER_TRAINING,
    THREAT_EVENTS,
    DANGEROUS_LINKS,
    BLOCKED_CALLS,
    SYSTEM_RECALCULATION
}

@Serializable
data class ScoreFactor(
    val category: FactorCategory,
    val name: String,
    val currentPoints: Int,
    val maxPoints: Int,
    val status: FactorStatus,
    val summary: String,
    val rules: List<TransparentRule>
) {
    val percentage: Float
        get() = if (maxPoints > 0) currentPoints.toFloat() / maxPoints.toFloat() else 0f
}

@Serializable
data class TransparentRule(
    val ruleId: String,
    val factorCategory: FactorCategory,
    val title: String,
    val description: String,
    val pointsAwarded: Int,
    val maxPoints: Int,
    val isSatisfied: Boolean,
    val explanation: String,
    val remediationAction: String? = null
)

@Serializable
data class ScoreDeltaEvent(
    val id: String,
    val timestamp: String,
    val previousScore: Int,
    val newScore: Int,
    val deltaPoints: Int,
    val factorCategory: FactorCategory,
    val triggerTitle: String,
    val reasonExplanation: String,
    val remediationAction: String? = null
) {
    val isPositive: Boolean get() = deltaPoints >= 0
    val deltaDisplay: String get() = if (deltaPoints > 0) "+$deltaPoints pts" else "$deltaPoints pts"
}

@Serializable
data class ActionableImprovement(
    val factorCategory: FactorCategory,
    val pointsPotential: Int,
    val actionTitle: String,
    val description: String
)

@Serializable
data class TrainingModule(
    val id: String,
    val moduleIndex: Int,
    val title: String,
    val description: String,
    val pointsReward: Int,
    val isCompleted: Boolean,
    val quizScorePercent: Int? = null
)
