package com.cyberguard.xai.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.cyberguard.xai.core.security.GoogleAuthClient
import com.cyberguard.xai.core.util.Resource
import com.cyberguard.xai.domain.model.AuthResult
import com.cyberguard.xai.domain.usecase.auth.ObserveSessionUseCase
import com.cyberguard.xai.domain.usecase.auth.ResendVerificationEmailUseCase
import com.cyberguard.xai.domain.usecase.auth.SignInWithEmailUseCase
import com.cyberguard.xai.domain.usecase.auth.SignInWithGoogleUseCase
import com.cyberguard.xai.domain.usecase.auth.SignOutUseCase
import com.cyberguard.xai.domain.usecase.auth.SignUpWithEmailUseCase
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class AuthViewModel(
    private val signInWithEmailUseCase: SignInWithEmailUseCase,
    private val signUpWithEmailUseCase: SignUpWithEmailUseCase,
    private val signInWithGoogleUseCase: SignInWithGoogleUseCase,
    private val resendVerificationEmailUseCase: ResendVerificationEmailUseCase,
    private val signOutUseCase: SignOutUseCase,
    private val observeSessionUseCase: ObserveSessionUseCase,
    private val googleAuthClient: GoogleAuthClient
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState = _uiState.asStateFlow()

    private val _navigationEffect = MutableSharedFlow<AuthNavigationEffect>()
    val navigationEffect = _navigationEffect.asSharedFlow()

    init {
        // Observe persistent session updates
        viewModelScope.launch {
            observeSessionUseCase().collect { session ->
                _uiState.update { it.copy(authenticatedSession = session) }
                if (session != null && session.accessToken.isNotBlank()) {
                    _navigationEffect.emit(AuthNavigationEffect.NavigateToDashboard)
                }
            }
        }
    }

    fun onEvent(event: AuthUiEvent) {
        when (event) {
            is AuthUiEvent.EmailChanged -> _uiState.update {
                it.copy(emailInput = event.email, errorMessage = null)
            }
            is AuthUiEvent.PasswordChanged -> _uiState.update {
                it.copy(passwordInput = event.password, errorMessage = null)
            }
            is AuthUiEvent.NameChanged -> _uiState.update {
                it.copy(nameInput = event.name, errorMessage = null)
            }
            is AuthUiEvent.ToggleAuthMode -> _uiState.update {
                it.copy(
                    isSignUpMode = !it.isSignUpMode,
                    errorMessage = null,
                    infoMessage = null,
                    emailVerificationPending = false
                )
            }
            is AuthUiEvent.TogglePasswordVisibility -> _uiState.update {
                it.copy(isPasswordVisible = !it.isPasswordVisible)
            }
            is AuthUiEvent.SubmitAuth -> submitEmailAuth()
            is AuthUiEvent.InitiateGoogleSignIn -> startGoogleSignIn()
            is AuthUiEvent.ResendVerificationEmail -> resendVerification()
            is AuthUiEvent.ClearMessages -> _uiState.update {
                it.copy(errorMessage = null, infoMessage = null)
            }
            is AuthUiEvent.PopulateDemoCredentials -> _uiState.update {
                it.copy(
                    emailInput = "agent@cyberguard.ai",
                    passwordInput = "CyberDefense2026!",
                    nameInput = "Alex Vance",
                    errorMessage = null,
                    infoMessage = null
                )
            }
        }
    }

    private fun submitEmailAuth() {
        val state = _uiState.value
        _uiState.update { it.copy(isLoading = true, errorMessage = null, infoMessage = null) }

        viewModelScope.launch {
            val result = if (state.isSignUpMode) {
                signUpWithEmailUseCase(
                    email = state.emailInput.trim(),
                    password = state.passwordInput,
                    fullName = state.nameInput.trim()
                )
            } else {
                signInWithEmailUseCase(
                    email = state.emailInput.trim(),
                    password = state.passwordInput
                )
            }

            when (result) {
                is Resource.Success -> {
                    when (val authResult = result.data) {
                        is AuthResult.Authenticated -> {
                            _uiState.update {
                                it.copy(
                                    isLoading = false,
                                    authenticatedSession = authResult.session,
                                    emailVerificationPending = false
                                )
                            }
                            _navigationEffect.emit(AuthNavigationEffect.NavigateToDashboard)
                        }
                        is AuthResult.EmailVerificationRequired -> {
                            _uiState.update {
                                it.copy(
                                    isLoading = false,
                                    emailVerificationPending = true,
                                    pendingVerificationEmail = authResult.email,
                                    infoMessage = "Verification link sent! Please check your inbox and verify your email before logging in."
                                )
                            }
                        }
                    }
                }
                is Resource.Error -> {
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = result.message)
                    }
                }
                is Resource.Loading -> {
                    _uiState.update { it.copy(isLoading = true) }
                }
            }
        }
    }

    private fun startGoogleSignIn() {
        _uiState.update { it.copy(isGoogleLoading = true, errorMessage = null, infoMessage = null) }

        viewModelScope.launch {
            when (val tokenResult = googleAuthClient.signInWithGoogle()) {
                is Resource.Success -> {
                    val authResult = signInWithGoogleUseCase(tokenResult.data)
                    when (authResult) {
                        is Resource.Success -> {
                            when (val res = authResult.data) {
                                is AuthResult.Authenticated -> {
                                    _uiState.update {
                                        it.copy(
                                            isGoogleLoading = false,
                                            authenticatedSession = res.session
                                        )
                                    }
                                    _navigationEffect.emit(AuthNavigationEffect.NavigateToDashboard)
                                }
                                is AuthResult.EmailVerificationRequired -> {
                                    _uiState.update {
                                        it.copy(
                                            isGoogleLoading = false,
                                            infoMessage = "Please verify your email to proceed."
                                        )
                                    }
                                }
                            }
                        }
                        is Resource.Error -> {
                            _uiState.update {
                                it.copy(isGoogleLoading = false, errorMessage = authResult.message)
                            }
                        }
                        is Resource.Loading -> Unit
                    }
                }
                is Resource.Error -> {
                    _uiState.update {
                        it.copy(isGoogleLoading = false, errorMessage = tokenResult.message)
                    }
                }
                is Resource.Loading -> Unit
            }
        }
    }

    private fun resendVerification() {
        val email = _uiState.value.pendingVerificationEmail.ifBlank { _uiState.value.emailInput }
        if (email.isBlank()) return

        _uiState.update { it.copy(isLoading = true) }
        viewModelScope.launch {
            when (val result = resendVerificationEmailUseCase(email)) {
                is Resource.Success -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            infoMessage = "A fresh verification link has been dispatched to $email."
                        )
                    }
                }
                is Resource.Error -> {
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = result.message)
                    }
                }
                is Resource.Loading -> Unit
            }
        }
    }

    fun signOut() {
        viewModelScope.launch {
            signOutUseCase()
            _uiState.update {
                it.copy(authenticatedSession = null, emailVerificationPending = false)
            }
        }
    }

    companion object {
        fun provideFactory(
            signInWithEmailUseCase: SignInWithEmailUseCase,
            signUpWithEmailUseCase: SignUpWithEmailUseCase,
            signInWithGoogleUseCase: SignInWithGoogleUseCase,
            resendVerificationEmailUseCase: ResendVerificationEmailUseCase,
            signOutUseCase: SignOutUseCase,
            observeSessionUseCase: ObserveSessionUseCase,
            googleAuthClient: GoogleAuthClient
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return AuthViewModel(
                    signInWithEmailUseCase,
                    signUpWithEmailUseCase,
                    signInWithGoogleUseCase,
                    resendVerificationEmailUseCase,
                    signOutUseCase,
                    observeSessionUseCase,
                    googleAuthClient
                ) as T
            }
        }
    }
}
