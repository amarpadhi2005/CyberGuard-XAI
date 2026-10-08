package com.cyberguard.xai.core.security

import android.content.Context
import com.cyberguard.xai.domain.model.UserSession
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class SessionManager(context: Context) {

    private val secureStorage = SecureStorage(context)
    private val _currentSession = MutableStateFlow<UserSession?>(null)
    val currentSession: StateFlow<UserSession?> = _currentSession.asStateFlow()

    init {
        // Attempt restoring persisted session on app launch
        restoreSession()
    }

    private fun restoreSession() {
        val token = secureStorage.getAccessToken()
        val userId = secureStorage.getUserId()
        val email = secureStorage.getUserEmail()

        if (!token.isNullOrBlank() && !userId.isNullOrBlank() && !email.isNullOrBlank()) {
            _currentSession.value = UserSession(
                userId = userId,
                email = email,
                accessToken = token,
                refreshToken = secureStorage.getRefreshToken(),
                isProtectionActive = secureStorage.isProtectionActive()
            )
        } else {
            _currentSession.value = null
        }
    }

    fun saveSession(session: UserSession) {
        secureStorage.saveTokens(session.accessToken, session.refreshToken)
        secureStorage.saveUserSession(session.userId, session.email)
        secureStorage.setProtectionActive(session.isProtectionActive)
        _currentSession.value = session
    }

    fun updateTokens(accessToken: String, refreshToken: String?, expiresAt: Long? = null) {
        val current = _currentSession.value ?: return
        val updated = current.copy(
            accessToken = accessToken,
            refreshToken = refreshToken ?: current.refreshToken,
            expiresAt = expiresAt ?: current.expiresAt
        )
        secureStorage.saveTokens(updated.accessToken, updated.refreshToken)
        _currentSession.value = updated
    }

    fun clearSession() {
        secureStorage.clearSession()
        _currentSession.value = null
    }

    fun isSessionValid(): Boolean {
        val session = _currentSession.value ?: return false
        val expiresAt = session.expiresAt ?: return session.accessToken.isNotBlank()
        // Buffer of 60 seconds before actual token expiry
        return System.currentTimeMillis() < (expiresAt - 60_000)
    }

    fun getAccessToken(): String? = _currentSession.value?.accessToken ?: secureStorage.getAccessToken()

    fun getUserId(): String? = _currentSession.value?.userId ?: secureStorage.getUserId()

    fun getUserEmail(): String? = _currentSession.value?.email ?: secureStorage.getUserEmail()
}
