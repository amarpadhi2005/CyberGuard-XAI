package com.cyberguard.xai.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cyberguard.xai.core.theme.RiskCritical
import com.cyberguard.xai.core.theme.RiskHigh
import com.cyberguard.xai.core.theme.RiskLow
import com.cyberguard.xai.core.theme.RiskMedium
import com.cyberguard.xai.core.theme.RiskSafe

enum class RiskSeverity(val label: String, val color: Color) {
    SAFE("SAFE", RiskSafe),
    LOW("LOW RISK", RiskLow),
    MEDIUM("SUSPICIOUS", RiskMedium),
    HIGH("HIGH RISK", RiskHigh),
    CRITICAL("CRITICAL THREAT", RiskCritical)
}

@Composable
fun RiskBadge(
    severity: RiskSeverity,
    modifier: Modifier = Modifier
) {
    val shape = RoundedCornerShape(8.dp)

    Box(
        modifier = modifier
            .clip(shape)
            .background(severity.color.copy(alpha = 0.15f))
            .border(1.dp, severity.color.copy(alpha = 0.5f), shape)
            .padding(horizontal = 10.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(6.dp)
                    .clip(CircleShape)
                    .background(severity.color)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = severity.label,
                color = severity.color,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.5.sp
            )
        }
    }
}
