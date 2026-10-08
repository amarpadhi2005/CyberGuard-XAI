package com.cyberguard.xai.presentation.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.theme.CyberBackground
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberPink
import com.cyberguard.xai.core.theme.CyberText
import com.cyberguard.xai.core.theme.CyberTextMuted
import com.cyberguard.xai.presentation.components.GradientButton

private data class OnboardingPage(
    val icon: ImageVector,
    val title: String,
    val description: String
)

@Composable
fun OnboardingScreen(
    onFinishOnboarding: () -> Unit
) {
    val pages = remember {
        listOf(
            OnboardingPage(
                icon = Icons.Default.Call,
                title = "AI Call Identification & Screening",
                description = "Screen incoming unknown calls in real time. Our on-device and cloud telemetry detects VoIP spoofing and automated robocall campaigns before you answer."
            ),
            OnboardingPage(
                icon = Icons.Default.NotificationsActive,
                title = "Notification Threat Sniffer",
                description = "Automatically inspect notification snippets for coercive language, smishing links, and fraudulent bank alerts without leaking private messages."
            ),
            OnboardingPage(
                icon = Icons.Default.Psychology,
                title = "Transparent Explainable AI (XAI)",
                description = "Every risk assessment gives you clear, human-understandable evidence, confidence scores, and instant countermeasure actions."
            )
        )
    }

    var currentPage by remember { mutableIntStateOf(0) }
    val isLastPage = currentPage == pages.size - 1

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CyberBackground)
            .padding(24.dp)
    ) {
        // Skip Button
        if (!isLastPage) {
            TextButton(
                onClick = onFinishOnboarding,
                modifier = Modifier.align(Alignment.TopEnd)
            ) {
                Text(text = "SKIP", color = CyberTextMuted, fontWeight = FontWeight.SemiBold)
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(vertical = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            val page = pages[currentPage]

            // Icon Glow Container
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(130.dp)
                    .clip(CircleShape)
                    .background(CyberCard)
                    .border(2.dp, Brush.linearGradient(listOf(CyberCyan, CyberPink)), CircleShape)
            ) {
                Icon(
                    imageVector = page.icon,
                    contentDescription = null,
                    tint = CyberCyan,
                    modifier = Modifier.size(64.dp)
                )
            }

            Spacer(modifier = Modifier.height(36.dp))

            Text(
                text = page.title,
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = CyberText
                ),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = page.description,
                style = MaterialTheme.typography.bodyMedium.copy(
                    fontSize = 14.sp,
                    color = CyberTextMuted,
                    lineHeight = 22.sp
                ),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            Spacer(modifier = Modifier.height(36.dp))

            // Indicator Dots
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                pages.forEachIndexed { index, _ ->
                    val isSelected = index == currentPage
                    Box(
                        modifier = Modifier
                            .padding(horizontal = 4.dp)
                            .size(if (isSelected) 10.dp else 7.dp)
                            .clip(CircleShape)
                            .background(if (isSelected) CyberCyan else CyberCardBorder)
                    )
                }
            }

            Spacer(modifier = Modifier.height(48.dp))

            GradientButton(
                text = if (isLastPage) "GET STARTED" else "CONTINUE",
                onClick = {
                    if (isLastPage) {
                        onFinishOnboarding()
                    } else {
                        currentPage++
                    }
                }
            )
        }
    }
}
