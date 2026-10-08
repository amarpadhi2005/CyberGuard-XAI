package com.cyberguard.xai.domain.repository

import com.cyberguard.xai.core.util.Resource
import com.cyberguard.xai.domain.model.AuthResult
import com.cyberguard.xai.domain.model.UserSession
import kotlinx.coroutines.flow.Flow

interface AuthRepository {
    suspend fun signUpWithEmail(email: String, password: String, fullName: String): Resource<AuthResult>
    suspend fun signInWithEmail(email: String, password: String): Resource<AuthResult>
    suspend fun signInWithGoogle(idToken: String): Resource<AuthResult>
    suspend fun resendVerificationEmail(email: String): Resource<Unit>
    suspend fun signOut(): Resource<Unit>
    suspend fun refreshSession(): Resource<UserSession>
    fun getCurrentSession(): UserSession?
    fun observeSession(): Flow<UserSession?>
    fun isSessionValid(): Boolean
}
