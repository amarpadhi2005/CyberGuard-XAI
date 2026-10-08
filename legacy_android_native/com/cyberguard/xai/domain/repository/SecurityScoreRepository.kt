package com.cyberguard.xai.domain.repository

import com.cyberguard.xai.domain.model.FactorCategory
import com.cyberguard.xai.domain.model.PersonalSecurityScore
import com.cyberguard.xai.domain.model.ScoreDeltaEvent
import com.cyberguard.xai.domain.model.TrainingModule
import kotlinx.coroutines.flow.Flow

interface SecurityScoreRepository {
    fun getSecurityScore(): Flow<PersonalSecurityScore>
    fun getScoreHistory(): Flow<List<ScoreDeltaEvent>>
    fun getTrainingModules(): Flow<List<TrainingModule>>
    suspend fun recalculateScore(): Result<PersonalSecurityScore>
    suspend fun completeTrainingModule(moduleIndex: Int): Result<PersonalSecurityScore>
    suspend fun toggleProtectionSetting(category: FactorCategory, enabled: Boolean): Result<PersonalSecurityScore>
    suspend fun resolveThreatEvent(threatType: String): Result<PersonalSecurityScore>
}
