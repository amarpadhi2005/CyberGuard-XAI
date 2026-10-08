package com.cyberguard.xai.presentation.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.cyberguard.xai.core.theme.CyberCard
import com.cyberguard.xai.core.theme.CyberCardBorder
import com.cyberguard.xai.core.theme.CyberCyan
import com.cyberguard.xai.core.theme.CyberPink

@Composable
fun CyberCard(
    modifier: Modifier = Modifier,
    shapeRadius: Dp = 16.dp,
    borderColor: Color? = null,
    gradientBorder: Brush? = null,
    backgroundColor: Color = CyberCard,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit
) {
    val shape = RoundedCornerShape(shapeRadius)
    val borderModifier = when {
        gradientBorder != null -> Modifier
        borderColor != null -> Modifier
        else -> Modifier
    }

    Surface(
        modifier = modifier
            .clip(shape)
            .then(
                if (onClick != null) Modifier.clickable { onClick() } else Modifier
            ),
        shape = shape,
        color = backgroundColor,
        border = BorderStroke(
            1.dp,
            gradientBorder ?: Brush.linearGradient(
                listOf(
                    borderColor ?: CyberCardBorder,
                    (borderColor ?: CyberCardBorder).copy(alpha = 0.3f)
                )
            )
        ),
        tonalElevation = 6.dp
    ) {
        Box(modifier = Modifier.padding(16.dp)) {
            content()
        }
    }
}
