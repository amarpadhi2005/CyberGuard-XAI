package com.cyberguard.xai.presentation

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.runtime.LaunchedEffect
import androidx.navigation.compose.rememberNavController
import com.cyberguard.xai.CyberGuardApp
import com.cyberguard.xai.core.theme.CyberGuardTheme
import com.cyberguard.xai.presentation.auth.AuthViewModel
import com.cyberguard.xai.presentation.navigation.CyberGuardNavGraph
import com.cyberguard.xai.presentation.navigation.Screen
import com.cyberguard.xai.services.notification.CyberNotificationDispatcher

class MainActivity : ComponentActivity() {

    private val authViewModel: AuthViewModel by viewModels {
        val app = application as CyberGuardApp
        AuthViewModel.provideFactory(
            signInWithEmailUseCase = app.signInWithEmailUseCase,
            signUpWithEmailUseCase = app.signUpWithEmailUseCase,
            signInWithGoogleUseCase = app.signInWithGoogleUseCase,
            resendVerificationEmailUseCase = app.resendVerificationEmailUseCase,
            signOutUseCase = app.signOutUseCase,
            observeSessionUseCase = app.observeSessionUseCase,
            googleAuthClient = app.googleAuthClient
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CyberNotificationDispatcher.createNotificationChannel(applicationContext)

        val targetThreatId = intent?.getStringExtra("OPEN_THREAT_ID")

        setContent {
            CyberGuardTheme {
                val navController = rememberNavController()

                LaunchedEffect(targetThreatId) {
                    if (!targetThreatId.isNullOrBlank()) {
                        navController.navigate(Screen.ThreatDetails.createRoute(targetThreatId))
                    }
                }

                CyberGuardNavGraph(
                    navController = navController,
                    authViewModel = authViewModel
                )
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
