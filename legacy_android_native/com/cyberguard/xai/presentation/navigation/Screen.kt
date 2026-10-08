package com.cyberguard.xai.presentation.navigation

sealed class Screen(val route: String) {
    data object Splash : Screen("splash")
    data object Onboarding : Screen("onboarding")
    data object Login : Screen("login")
    data object Register : Screen("register")
    data object HomeDashboard : Screen("home_dashboard")
    data object ProtectionCenter : Screen("protection_center")
    data object CallProtection : Screen("call_protection")
    data object NotificationProtection : Screen("notification_protection")
    data object UrlScanner : Screen("url_scanner")
    data object QrScanner : Screen("qr_scanner")
    data object DeepfakeScanner : Screen("deepfake_scanner")
    data object AiAssistant : Screen("ai_assistant")
    data object ThreatHistory : Screen("threat_history")
    data object ThreatDetails : Screen("threat_details/{threatId}") {
        fun createRoute(threatId: String) = "threat_details/$threatId"
    }
    data object SecurityScore : Screen("security_score")
    data object Settings : Screen("settings")
    data object PrivacyCenter : Screen("privacy_center")
    data object ThreatDna : Screen("threat_dna")
}
