package com.cyberguard.xai.presentation.score

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.cyberguard.xai.data.repository.SecurityScoreRepositoryImpl
import com.cyberguard.xai.domain.model.FactorCategory
import com.cyberguard.xai.domain.model.PersonalSecurityScore
import com.cyberguard.xai.domain.model.ScoreDeltaEvent
import com.cyberguard.xai.domain.model.TrainingModule
import com.cyberguard.xai.domain.repository.SecurityScoreRepository
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class SecurityScoreUiState(
    val isLoading: Boolean = false,
    val score: PersonalSecurityScore? = null,
    val scoreHistory: List<ScoreDeltaEvent> = emptyList(),
    val trainingModules: List<TrainingModule> = emptyList(),
    val selectedFactor: FactorCategory? = null,
    val showRulesModal: Boolean = false,
    val showHistoryModal: Boolean = false,
    val feedbackMessage: String? = null
)

sealed interface ScoreUiEvent {
    data object Recalculate : ScoreUiEvent
    data class CompleteTraining(val moduleIndex: Int) : ScoreUiEvent
    data class ToggleProtection(val category: FactorCategory, val enabled: Boolean) : ScoreUiEvent
    data class ResolveThreat(val threatType: String) : ScoreUiEvent
    data class SelectFactor(val category: FactorCategory?) : ScoreUiEvent
    data class ShowRules(val show: Boolean) : ScoreUiEvent
    data class ShowHistory(val show: Boolean) : ScoreUiEvent
    data object ClearFeedback : ScoreUiEvent
}

class SecurityScoreViewModel(
    private val repository: SecurityScoreRepository = SecurityScoreRepositoryImpl()
) : ViewModel() {

    private val _uiState = MutableStateFlow(SecurityScoreUiState(isLoading = true))
    val uiState: StateFlow<SecurityScoreUiState> = _uiState.asStateFlow()

    private val _navigationEffect = MutableSharedFlow<String>()
    val navigationEffect: SharedFlow<String> = _navigationEffect.asSharedFlow()

    init {
        observeScore()
        observeHistory()
        observeTraining()
    }

    private fun observeScore() {
        viewModelScope.launch {
            repository.getSecurityScore().collect { score ->
                _uiState.update { it.copy(score = score, isLoading = false) }
            }
        }
    }

    private fun observeHistory() {
        viewModelScope.launch {
            repository.getScoreHistory().collect { history ->
                _uiState.update { it.copy(scoreHistory = history) }
            }
        }
    }

    private fun observeTraining() {
        viewModelScope.launch {
            repository.getTrainingModules().collect { modules ->
                _uiState.update { it.copy(trainingModules = modules) }
            }
        }
    }

    fun onEvent(event: ScoreUiEvent) {
        when (event) {
            is ScoreUiEvent.Recalculate -> recalculate()
            is ScoreUiEvent.CompleteTraining -> completeTraining(event.moduleIndex)
            is ScoreUiEvent.ToggleProtection -> toggleProtection(event.category, event.enabled)
            is ScoreUiEvent.ResolveThreat -> resolveThreat(event.threatType)
            is ScoreUiEvent.SelectFactor -> _uiState.update { it.copy(selectedFactor = event.category) }
            is ScoreUiEvent.ShowRules -> _uiState.update { it.copy(showRulesModal = event.show) }
            is ScoreUiEvent.ShowHistory -> _uiState.update { it.copy(showHistoryModal = event.show) }
            is ScoreUiEvent.ClearFeedback -> _uiState.update { it.copy(feedbackMessage = null) }
        }
    }

    private fun recalculate() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val res = repository.recalculateScore()
            res.onSuccess {
                _uiState.update { state ->
                    state.copy(isLoading = false, feedbackMessage = "Telemetry Score successfully synchronized!")
                }
            }.onFailure {
                _uiState.update { state ->
                    state.copy(isLoading = false, feedbackMessage = "Recalculation error: ${it.localizedMessage}")
                }
            }
        }
    }

    private fun completeTraining(moduleIndex: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val res = repository.completeTrainingModule(moduleIndex)
            res.onSuccess { score ->
                _uiState.update { state ->
                    state.copy(
                        isLoading = false,
                        feedbackMessage = "Module completed! Score elevated to ${score.overallScore}."
                    )
                }
            }
        }
    }

    private fun toggleProtection(category: FactorCategory, enabled: Boolean) {
        viewModelScope.launch {
            val res = repository.toggleProtectionSetting(category, enabled)
            res.onSuccess { score ->
                val action = if (enabled) "activated" else "deactivated"
                _uiState.update { state ->
                    state.copy(feedbackMessage = "${category.name.replace('_', ' ')} $action. Score updated to ${score.overallScore}.")
                }
            }
        }
    }

    private fun resolveThreat(threatType: String) {
        viewModelScope.launch {
            val res = repository.resolveThreatEvent(threatType)
            res.onSuccess { score ->
                _uiState.update { state ->
                    state.copy(feedbackMessage = "Threat quarantined! Recovered points. New score: ${score.overallScore}.")
                }
            }
        }
    }

    companion object {
        fun provideFactory(
            repository: SecurityScoreRepository = SecurityScoreRepositoryImpl()
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return SecurityScoreViewModel(repository) as T
            }
        }
    }
}
