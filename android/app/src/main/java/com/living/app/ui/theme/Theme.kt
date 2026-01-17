package com.living.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// Colors
val SumiBlack = Color(0xFF1A1A1A)
val CheckInGreen = Color(0xFF22C55E)
val TextWhite = Color(0xFFFFFFFF)
val TextGray = Color(0xFF9CA3AF)

private val DarkColorScheme = darkColorScheme(
    primary = CheckInGreen,
    secondary = CheckInGreen,
    background = SumiBlack,
    surface = SumiBlack,
    onPrimary = TextWhite,
    onSecondary = TextWhite,
    onBackground = TextWhite,
    onSurface = TextWhite
)

@Composable
fun LivingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content
    )
}
