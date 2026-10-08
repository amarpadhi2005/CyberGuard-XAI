package com.cyberguard.xai.core.security

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class SecureStorage(context: Context) {

    private val masterKey: MasterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs: SharedPreferences = try {
        EncryptedSharedPreferences.create(
            context,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    } catch (e: Exception) {
        // Fallback for devices with corrupted keystore during rapid reinstall in development
        context.deleteSharedPreferences(PREFS_FILE_NAME)
        EncryptedSharedPreferences.create(
            context,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun saveTokens(accessToken: String, refreshToken: String?) {
        prefs.edit()
            .putString(KEY_ACCESS_TOKEN, accessToken)
            .putString(KEY_REFRESH_TOKEN, refreshToken)
            .apply()
    }

    fun getAccessToken(): String? = prefs.getString(KEY_ACCESS_TOKEN, null)

    fun getRefreshToken(): String? = prefs.getString(KEY_REFRESH_TOKEN, null)

    fun saveUserSession(userId: String, email: String) {
        prefs.edit()
            .putString(KEY_USER_ID, userId)
            .putString(KEY_USER_EMAIL, email)
            .apply()
    }

    fun getUserId(): String? = prefs.getString(KEY_USER_ID, null)

    fun getUserEmail(): String? = prefs.getString(KEY_USER_EMAIL, null)

    fun setProtectionActive(active: Boolean) {
        prefs.edit().putBoolean(KEY_PROTECTION_ACTIVE, active).apply()
    }

    fun isProtectionActive(): Boolean = prefs.getBoolean(KEY_PROTECTION_ACTIVE, true)

    fun clearSession() {
        prefs.edit()
            .remove(KEY_ACCESS_TOKEN)
            .remove(KEY_REFRESH_TOKEN)
            .remove(KEY_USER_ID)
            .remove(KEY_USER_EMAIL)
            .apply()
    }

    fun saveFcmToken(token: String) {
        prefs.edit().putString(KEY_FCM_TOKEN, token).apply()
    }

    fun getFcmToken(): String? = prefs.getString(KEY_FCM_TOKEN, null)

    fun addBlockedSource(source: String) {
        val trimmed = source.trim()
        if (trimmed.isNotBlank()) {
            val current = getBlockedSources().toMutableSet()
            current.add(trimmed)
            prefs.edit().putStringSet(KEY_BLOCKED_SOURCES, current).apply()
        }
    }

    fun getBlockedSources(): Set<String> {
        return prefs.getStringSet(KEY_BLOCKED_SOURCES, emptySet()) ?: emptySet()
    }

    fun isSourceBlocked(source: String): Boolean {
        val trimmed = source.trim()
        if (trimmed.isBlank()) return false
        val blocked = getBlockedSources()
        return blocked.any { it.equals(trimmed, ignoreCase = true) || trimmed.contains(it, ignoreCase = true) }
    }

    companion object {
        private const val PREFS_FILE_NAME = "cyberguard_secure_prefs"
        private const val KEY_ACCESS_TOKEN = "jwt_access_token"
        private const val KEY_REFRESH_TOKEN = "jwt_refresh_token"
        private const val KEY_USER_ID = "authenticated_user_id"
        private const val KEY_USER_EMAIL = "authenticated_user_email"
        private const val KEY_PROTECTION_ACTIVE = "protection_active"
        private const val KEY_FCM_TOKEN = "fcm_registration_token"
        private const val KEY_BLOCKED_SOURCES = "blocked_threat_sources"
    }
}
