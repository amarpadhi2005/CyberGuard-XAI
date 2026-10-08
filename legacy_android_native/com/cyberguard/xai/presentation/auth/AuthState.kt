package com.cyberguard.xai.presentation.auth

import com.cyberguard.xai.domain.model.UserSession

data class AuthUiState(
    val isLoading: Boolean = false,
    val isGoogleLoading: Boolean = false,
    val isSignUpMode: Boolean = false,
    val emailInput: String = "",
    val passwordInput: String = "",
    val nameInput: String = "",
    val isPasswordVisible: Boolean = false,
    val errorMessage: String? = null,
    val infoMessage: String? = null,
    val emailVerificationPending: Boolean = false,
    val pendingVerificationEmail: String = "",
    val authenticatedSession: UserSession? = null
)

sealed interface AuthUiEvent {
    data class EmailChanged(val email: String) : AuthUiEvent
    data class PasswordChanged(val password: String) : AuthUiEvent
    data class NameChanged(val name: String) : AuthUiEvent
    data object ToggleAuthMode : AuthUiEvent
    data object TogglePasswordVisibility : AuthUiEvent
    data object SubmitAuth : AuthUiEvent
    data object InitiateGoogleSignIn : AuthUiEvent
    data object ResendVerificationEmail : AuthUiEvent
    data object ClearMessages : AuthUiEvent
    data object PopulateDemoCredentials : AuthUiEvent
}

sealed interface AuthNavigationEffect {
    data object NavigateToDashboard : AuthNavigationEffect
    data class ShowToast(val message: String) : AuthNavigationEffect
}
