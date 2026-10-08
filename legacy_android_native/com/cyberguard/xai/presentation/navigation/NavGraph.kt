package com.cyberguard.xai.presentation.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.navArgument
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.presentation.assistant.AiAssistantScreen
import com.cyberguard.xai.presentation.auth.AuthViewModel
import com.cyberguard.xai.presentation.auth.LoginScreen
import com.cyberguard.xai.presentation.auth.RegisterScreen
import com.cyberguard.xai.presentation.components.CyberBottomNavigation
import com.cyberguard.xai.presentation.components.CyberTopBar
import com.cyberguard.xai.presentation.home.HomeDashboardScreen
import com.cyberguard.xai.presentation.onboarding.OnboardingScreen
import com.cyberguard.xai.presentation.privacy.PrivacyCenterScreen
import com.cyberguard.xai.presentation.protection.CallProtectionScreen
import com.cyberguard.xai.presentation.protection.NotificationProtectionScreen
import com.cyberguard.xai.presentation.protection.ProtectionCenterScreen
import com.cyberguard.xai.presentation.scanner.DeepfakeScannerScreen
import com.cyberguard.xai.presentation.scanner.QrScannerScreen
import com.cyberguard.xai.presentation.scanner.UrlScannerScreen
import com.cyberguard.xai.presentation.score.SecurityScoreScreen
import com.cyberguard.xai.presentation.settings.SettingsScreen
import com.cyberguard.xai.presentation.splash.SplashScreen
import com.cyberguard.xai.presentation.threats.ThreatDetailsScreen
import com.cyberguard.xai.presentation.threats.ThreatDnaScreen
import com.cyberguard.xai.presentation.threats.ThreatHistoryScreen

@Composable
fun CyberGuardNavGraph(
    navController: NavHostController,
    authViewModel: AuthViewModel,
    startDestination: String = Screen.Splash.route
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route ?: ""
    val authState by authViewModel.uiState.collectAsState()

    // Determine bar visibilities
    val isBottomBarVisible = currentRoute in listOf(
        Screen.HomeDashboard.route,
        Screen.ProtectionCenter.route,
        Screen.UrlScanner.route,
        Screen.AiAssistant.route,
        Screen.ThreatHistory.route
    )

    val isTopBarVisible = currentRoute !in listOf(
        Screen.Splash.route,
        Screen.Onboarding.route,
        Screen.Login.route,
        Screen.Register.route
    )

    val topBarTitle = when (currentRoute) {
        Screen.HomeDashboard.route -> "CyberGuard XAI"
        Screen.ProtectionCenter.route -> "Protection Center"
        Screen.CallProtection.route -> "Call Screening Engine"
        Screen.NotificationProtection.route -> "Notification Sniffer"
        Screen.UrlScanner.route -> "URL Phishing Scanner"
        Screen.QrScanner.route -> "QR Code Scam Shield"
        Screen.DeepfakeScanner.route -> "Deepfake AI Forensics"
        Screen.AiAssistant.route -> "AI Cyber Copilot"
        Screen.ThreatHistory.route -> "Threat Incident Log"
        Screen.SecurityScore.route -> "Personal Security Score"
        Screen.Settings.route -> "System & Cloud Config"
        Screen.PrivacyCenter.route -> "Zero-Knowledge Privacy"
        Screen.ThreatDna.route -> "Threat DNA Correlation"
        else -> if (currentRoute.startsWith("threat_details")) "Incident Investigation" else "CyberGuard XAI"
    }

    Scaffold(
        topBar = {
            if (isTopBarVisible) {
                val canNavigateBack = !isBottomBarVisible
                CyberTopBar(
                    title = topBarTitle,
                    subtitle = if (currentRoute == Screen.HomeDashboard.route) "Live Shield Active" else null,
                    onBackClick = if (canNavigateBack) { { navController.popBackStack() } } else null,
                    onSettingsClick = {
                        if (currentRoute != Screen.Settings.route) {
                            navController.navigate(Screen.Settings.route)
                        }
                    },
                    onPrivacyClick = {
                        if (currentRoute != Screen.PrivacyCenter.route) {
                            navController.navigate(Screen.PrivacyCenter.route)
                        }
                    },
                    scoreBadge = 88,
                    onScoreClick = {
                        if (currentRoute != Screen.SecurityScore.route) {
                            navController.navigate(Screen.SecurityScore.route)
                        }
                    }
                )
            }
        },
        bottomBar = {
            if (isBottomBarVisible) {
                CyberBottomNavigation(
                    currentRoute = currentRoute,
                    onNavigate = { targetRoute ->
                        if (currentRoute != targetRoute) {
                            navController.navigate(targetRoute) {
                                popUpTo(Screen.HomeDashboard.route) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    }
                )
            }
        },
        containerColor = CyberBackground
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(CyberBackground)
                .padding(innerPadding)
        ) {
            NavHost(
                navController = navController,
                startDestination = startDestination
            ) {
                // 1. Splash
                composable(Screen.Splash.route) {
                    SplashScreen(
                        onNavigateNext = {
                            if (authState.authenticatedSession != null) {
                                navController.navigate(Screen.HomeDashboard.route) {
                                    popUpTo(Screen.Splash.route) { inclusive = true }
                                }
                            } else {
                                navController.navigate(Screen.Onboarding.route) {
                                    popUpTo(Screen.Splash.route) { inclusive = true }
                                }
                            }
                        }
                    )
                }

                // 2. Onboarding
                composable(Screen.Onboarding.route) {
                    OnboardingScreen(
                        onFinishOnboarding = {
                            navController.navigate(Screen.Login.route) {
                                popUpTo(Screen.Onboarding.route) { inclusive = true }
                            }
                        }
                    )
                }

                // 3. Login
                composable(Screen.Login.route) {
                    LoginScreen(
                        viewModel = authViewModel,
                        onNavigateToRegister = {
                            navController.navigate(Screen.Register.route)
                        },
                        onLoginSuccess = {
                            navController.navigate(Screen.HomeDashboard.route) {
                                popUpTo(Screen.Login.route) { inclusive = true }
                            }
                        }
                    )
                }

                // 4. Register
                composable(Screen.Register.route) {
                    RegisterScreen(
                        viewModel = authViewModel,
                        onNavigateToLogin = {
                            navController.navigate(Screen.Login.route) {
                                popUpTo(Screen.Register.route) { inclusive = true }
                            }
                        },
                        onRegisterSuccess = {
                            navController.navigate(Screen.HomeDashboard.route) {
                                popUpTo(Screen.Register.route) { inclusive = true }
                            }
                        }
                    )
                }

                // 5. Home Dashboard
                composable(Screen.HomeDashboard.route) {
                    HomeDashboardScreen(
                        onNavigateToProtection = { navController.navigate(Screen.ProtectionCenter.route) },
                        onNavigateToUrlScanner = { navController.navigate(Screen.UrlScanner.route) },
                        onNavigateToQrScanner = { navController.navigate(Screen.QrScanner.route) },
                        onNavigateToDeepfake = { navController.navigate(Screen.DeepfakeScanner.route) },
                        onNavigateToAssistant = { navController.navigate(Screen.AiAssistant.route) },
                        onNavigateToHistory = { navController.navigate(Screen.ThreatHistory.route) },
                        onNavigateToThreatDetails = { threatId ->
                            navController.navigate(Screen.ThreatDetails.createRoute(threatId))
                        },
                        onNavigateToScoreDetails = { navController.navigate(Screen.SecurityScore.route) },
                        onNavigateToThreatDna = { navController.navigate(Screen.ThreatDna.route) }
                    )
                }

                // 6. Protection Center
                composable(Screen.ProtectionCenter.route) {
                    ProtectionCenterScreen(
                        onNavigateToCallProtection = { navController.navigate(Screen.CallProtection.route) },
                        onNavigateToNotificationProtection = { navController.navigate(Screen.NotificationProtection.route) }
                    )
                }

                // 7. Call Protection
                composable(Screen.CallProtection.route) {
                    CallProtectionScreen(
                        onBack = { navController.popBackStack() }
                    )
                }

                // 8. Notification Protection
                composable(Screen.NotificationProtection.route) {
                    NotificationProtectionScreen(
                        onBack = { navController.popBackStack() },
                        onNavigateToThreatDetails = { threatId ->
                            navController.navigate(Screen.ThreatDetails.createRoute(threatId))
                        }
                    )
                }

                // 9. URL Scanner
                composable(Screen.UrlScanner.route) {
                    UrlScannerScreen(
                        onNavigateToQrScanner = { navController.navigate(Screen.QrScanner.route) }
                    )
                }

                // 10. QR Scanner
                composable(Screen.QrScanner.route) {
                    QrScannerScreen(
                        onNavigateBack = { navController.popBackStack() }
                    )
                }

                // 11. Deepfake Scanner
                composable(Screen.DeepfakeScanner.route) {
                    DeepfakeScannerScreen()
                }

                // 12. AI Assistant
                composable(Screen.AiAssistant.route) {
                    AiAssistantScreen()
                }

                // 13. Threat History
                composable(Screen.ThreatHistory.route) {
                    ThreatHistoryScreen(
                        onNavigateToDetails = { threatId ->
                            navController.navigate(Screen.ThreatDetails.createRoute(threatId))
                        }
                    )
                }

                // 14. Threat Details
                composable(
                    route = Screen.ThreatDetails.route,
                    arguments = listOf(navArgument("threatId") { type = NavType.StringType })
                ) { backStackEntry ->
                    val threatId = backStackEntry.arguments?.getString("threatId") ?: "001"
                    ThreatDetailsScreen(
                        threatId = threatId,
                        onBack = { navController.popBackStack() },
                        onAskAssistant = { navController.navigate(Screen.AiAssistant.route) },
                        onNavigateToThreatDna = { navController.navigate(Screen.ThreatDna.route) }
                    )
                }

                // 15. Security Score
                composable(Screen.SecurityScore.route) {
                    SecurityScoreScreen(
                        onNavigateBack = { navController.popBackStack() }
                    )
                }

                // 16. Settings
                composable(Screen.Settings.route) {
                    SettingsScreen(
                        onNavigateToPrivacy = { navController.navigate(Screen.PrivacyCenter.route) },
                        onSignOut = {
                            authViewModel.signOut()
                            navController.navigate(Screen.Login.route) {
                                popUpTo(Screen.HomeDashboard.route) { inclusive = true }
                            }
                        }
                    )
                }

                // 17. Privacy Center
                composable(Screen.PrivacyCenter.route) {
                    PrivacyCenterScreen(
                        onNavigateBack = { navController.popBackStack() }
                    )
                }

                // 18. Threat DNA Correlation
                composable(Screen.ThreatDna.route) {
                    ThreatDnaScreen(
                        onNavigateBack = { navController.popBackStack() }
                    )
                }
            }
        }
    }
}
