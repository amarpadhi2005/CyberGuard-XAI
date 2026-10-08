package com.cyberguard.xai.domain.model

data class UserSession(
    val userId: String,
    val email: String,
    val fullName: String? = null,
    val accessToken: String,
    val refreshToken: String? = null,
    val expiresAt: Long? = null,
    val isEmailVerified: Boolean = true,
    val isProtectionActive: Boolean = true
)

sealed interface AuthResult {
    data class Authenticated(val session: UserSession) : AuthResult
    data class EmailVerificationRequired(val email: String) : AuthResult
}
