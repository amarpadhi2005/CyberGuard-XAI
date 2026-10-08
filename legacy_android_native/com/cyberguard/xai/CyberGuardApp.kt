package com.cyberguard.xai

import android.app.Application
import com.cyberguard.xai.core.security.GoogleAuthClient
import com.cyberguard.xai.core.security.SessionManager
import com.cyberguard.xai.data.repository.AuthRepositoryImpl
import com.cyberguard.xai.domain.repository.AuthRepository
import com.cyberguard.xai.domain.usecase.auth.ObserveSessionUseCase
import com.cyberguard.xai.domain.usecase.auth.ResendVerificationEmailUseCase
import com.cyberguard.xai.domain.usecase.auth.SignInWithEmailUseCase
import com.cyberguard.xai.domain.usecase.auth.SignInWithGoogleUseCase
import com.cyberguard.xai.domain.usecase.auth.SignOutUseCase
import com.cyberguard.xai.domain.usecase.auth.SignUpWithEmailUseCase

class CyberGuardApp : Application() {

    lateinit var sessionManager: SessionManager
        private set

    lateinit var authRepository: AuthRepository
        private set

    lateinit var googleAuthClient: GoogleAuthClient
        private set

    lateinit var signInWithEmailUseCase: SignInWithEmailUseCase
        private set

    lateinit var signUpWithEmailUseCase: SignUpWithEmailUseCase
        private set

    lateinit var signInWithGoogleUseCase: SignInWithGoogleUseCase
        private set

    lateinit var resendVerificationEmailUseCase: ResendVerificationEmailUseCase
        private set

    lateinit var signOutUseCase: SignOutUseCase
        private set

    lateinit var observeSessionUseCase: ObserveSessionUseCase
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this

        sessionManager = SessionManager(this)
        authRepository = AuthRepositoryImpl(sessionManager)
        googleAuthClient = GoogleAuthClient(this)

        signInWithEmailUseCase = SignInWithEmailUseCase(authRepository)
        signUpWithEmailUseCase = SignUpWithEmailUseCase(authRepository)
        signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository)
        resendVerificationEmailUseCase = ResendVerificationEmailUseCase(authRepository)
        signOutUseCase = SignOutUseCase(authRepository)
        observeSessionUseCase = ObserveSessionUseCase(authRepository)

        // Initialize Android Notification Channels for Threat Alerts, Scans, & Account Security
        com.cyberguard.xai.services.notification.NotificationChannelManager.createAllChannels(this)

        // Safe Firebase initialization
        try {
            if (com.google.firebase.FirebaseApp.getApps(this).isEmpty()) {
                val options = com.google.firebase.FirebaseOptions.Builder()
                    .setApplicationId("1:1234567890:android:cyberguardxai")
                    .setProjectId("cyberguard-xai")
                    .setApiKey("AIzaSyMockKeyForCyberGuardLocalEnv12345")
                    .build()
                com.google.firebase.FirebaseApp.initializeApp(this, options)
            }
        } catch (e: Exception) {
            android.util.Log.w("CyberGuardApp", "Firebase auto-init: ${e.message}")
        }
    }

    companion object {
        lateinit var instance: CyberGuardApp
            private set
    }
}
