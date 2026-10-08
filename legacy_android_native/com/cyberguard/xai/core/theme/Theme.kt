package com.cyberguard.xai.core.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val CyberDarkColorScheme = darkColorScheme(
    primary = CyberCyan,
    onPrimary = CyberTextDark,
    primaryContainer = CyberGlassBg,
    onPrimaryContainer = CyberCyan,
    secondary = CyberPink,
    onSecondary = CyberTextDark,
    secondaryContainer = CyberPinkBorder,
    onSecondaryContainer = CyberPink,
    tertiary = CyberPink,
    background = CyberBackground,
    onBackground = CyberText,
    surface = CyberCard,
    onSurface = CyberText,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = CyberTextMuted,
    error = RiskCritical,
    onError = CyberText
)

@Composable
fun CyberGuardTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = CyberDarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = CyberBackground.toArgb()
            window.navigationBarColor = CyberBackground.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = CyberTypography,
        content = content
    )
}
