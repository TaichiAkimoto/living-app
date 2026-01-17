package com.living.app.ui

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun SplashScreen() {
    var showLeftDot by remember { mutableStateOf(false) }
    var lineProgress by remember { mutableFloatStateOf(0f) }
    var showRightDot by remember { mutableStateOf(false) }
    var showAppName by remember { mutableStateOf(false) }

    // Glow animation
    val infiniteTransition = rememberInfiniteTransition(label = "glow")
    val glowScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.2f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowScale"
    )

    // Animation sequence
    LaunchedEffect(Unit) {
        // Phase 1: Show left dot
        delay(100)
        showLeftDot = true

        // Phase 2: Extend line
        delay(300)
        lineProgress = 1f

        // Phase 3: Show right dot
        delay(600)
        showRightDot = true

        // Phase 4: Show app name
        delay(300)
        showAppName = true
    }

    // Animated values
    val leftDotScale by animateFloatAsState(
        targetValue = if (showLeftDot) 1f else 0f,
        animationSpec = spring(dampingRatio = 0.6f, stiffness = 300f),
        label = "leftDotScale"
    )

    val animatedLineProgress by animateFloatAsState(
        targetValue = lineProgress,
        animationSpec = tween(600, easing = EaseInOut),
        label = "lineProgress"
    )

    val rightDotScale by animateFloatAsState(
        targetValue = if (showRightDot) 1f else 0f,
        animationSpec = spring(dampingRatio = 0.6f, stiffness = 300f),
        label = "rightDotScale"
    )

    val appNameAlpha by animateFloatAsState(
        targetValue = if (showAppName) 1f else 0f,
        animationSpec = tween(400),
        label = "appNameAlpha"
    )

    val greenColor = Color(0xFF4CAF50)
    val greenLight = Color(0xFF81C784)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Two dots animation
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                // Left dot with glow
                Box(contentAlignment = Alignment.Center) {
                    // Glow
                    Box(
                        modifier = Modifier
                            .size(60.dp)
                            .scale(if (showLeftDot) glowScale else 0f)
                            .alpha(if (showLeftDot) 0.3f else 0f)
                            .background(greenLight, CircleShape)
                    )
                    // Main dot
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .scale(leftDotScale)
                            .background(greenColor, CircleShape)
                    )
                }

                // Connecting line
                Box(
                    modifier = Modifier
                        .width((100 * animatedLineProgress).dp)
                        .height(4.dp)
                        .background(greenLight)
                )

                // Right dot with glow
                Box(contentAlignment = Alignment.Center) {
                    // Glow
                    Box(
                        modifier = Modifier
                            .size(60.dp)
                            .scale(if (showRightDot) glowScale else 0f)
                            .alpha(if (showRightDot) 0.3f else 0f)
                            .background(greenLight, CircleShape)
                    )
                    // Main dot
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .scale(rightDotScale)
                            .background(greenColor, CircleShape)
                    )
                }
            }

            Spacer(modifier = Modifier.height(48.dp))

            // App name
            Text(
                text = "生きろ。",
                fontSize = 28.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.alpha(appNameAlpha)
            )
        }
    }
}
