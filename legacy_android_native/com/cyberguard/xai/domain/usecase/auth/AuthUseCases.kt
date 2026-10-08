package com.cyberguard.xai.domain.usecase.auth

import com.cyberguard.xai.core.util.Resource
import com.cyberguard.xai.domain.model.AuthResult
import com.cyberguard.xai.domain.model.UserSession
import com.cyberguard.xai.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow

class SignInWithEmailUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(email: String, password: String): Resource<AuthResult> {
        val trimmedEmail = email.trim()
        if (trimmedEmail.isBlank() || !trimmedEmail.contains("@")) {
            return Resource.Error("Please enter a valid email address")
        }
        if (password.length < 6) {
            return Resource.Error("Password must be at least 6 characters")
        }
        return repository.signInWithEmail(trimmedEmail, password)
    }
}

class SignUpWithEmailUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(email: String, password: String, fullName: String): Resource<AuthResult> {
        val trimmedName = fullName.trim()
        val trimmedEmail = email.trim()
        if (trimmedName.isBlank()) {
            return Resource.Error("Full name is required")
        }
        if (trimmedEmail.isBlank() || !trimmedEmail.contains("@")) {
            return Resource.Error("Please enter a valid email address")
        }
        if (password.length < 6) {
            return Resource.Error("Password must contain at least 6 characters")
        }
        return repository.signUpWithEmail(trimmedEmail, password, trimmedName)
    }
}

class SignInWithGoogleUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(idToken: String): Resource<AuthResult> {
        if (idToken.isBlank()) {
            return Resource.Error("Google ID token cannot be empty")
        }
        return repository.signInWithGoogle(idToken)
    }
}

class ResendVerificationEmailUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(email: String): Resource<Unit> {
        if (email.isBlank() || !email.contains("@")) {
            return Resource.Error("Invalid email address for verification resend")
        }
        return repository.resendVerificationEmail(email.trim())
    }
}

class SignOutUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(): Resource<Unit> = repository.signOut()
}

class ObserveSessionUseCase(private val repository: AuthRepository) {
    operator fun invoke(): Flow<UserSession?> = repository.observeSession()
    fun getCurrentSession(): UserSession? = repository.getCurrentSession()
    fun isSessionValid(): Boolean = repository.isSessionValid()
}

class RefreshSessionUseCase(private val repository: AuthRepository) {
    suspend operator fun invoke(): Resource<UserSession> = repository.refreshSession()
}
