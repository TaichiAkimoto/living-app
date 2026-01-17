package com.living.app.ui

import android.text.format.DateUtils
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.living.app.data.UserRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.Date

@Composable
fun CheckInScreen(
    onSettingsClick: () -> Unit
) {
    val repository = remember { UserRepository() }

    var lastCheckIn by remember { mutableStateOf<Date?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var showSuccessAnimation by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        lastCheckIn = repository.getLastCheckIn()
    }

    val greenColor = Color(0xFF4CAF50)
    val greenLight = Color(0xFF81C784)

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.weight(1f))

            // Two dots animation
            ConnectionDotsAnimation(
                showSuccessAnimation = showSuccessAnimation,
                greenColor = greenColor,
                greenLight = greenLight
            )

            Spacer(modifier = Modifier.height(16.dp))

            // App name
            Text(
                text = "生きろ。",
                fontSize = 20.sp,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.weight(1f))

            // Check-in button
            Button(
                onClick = {
                    scope.launch {
                        isLoading = true
                        errorMessage = null
                        try {
                            repository.updateCheckIn()
                            lastCheckIn = Date()
                            // Play success animation
                            showSuccessAnimation = true
                            delay(1500)
                            showSuccessAnimation = false
                        } catch (e: Exception) {
                            errorMessage = "チェックインに失敗しました"
                        }
                        isLoading = false
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp)
                    .height(56.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = greenColor
                ),
                enabled = !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = MaterialTheme.colorScheme.onPrimary,
                        modifier = Modifier.size(24.dp)
                    )
                } else {
                    Row(
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "✓",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "確認する",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Last check-in time
            lastCheckIn?.let { date ->
                val relativeTime = DateUtils.getRelativeTimeSpanString(
                    date.time,
                    System.currentTimeMillis(),
                    DateUtils.MINUTE_IN_MILLIS
                )
                Text(
                    text = "最終確認: $relativeTime",
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Description
            Text(
                text = "2日間未確認で通知",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(modifier = Modifier.weight(1f))

            // Error display
            errorMessage?.let { error ->
                Surface(
                    color = MaterialTheme.colorScheme.error,
                    shape = MaterialTheme.shapes.small
                ) {
                    Text(
                        text = error,
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onError,
                        modifier = Modifier.padding(16.dp)
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Settings button
            TextButton(
                onClick = onSettingsClick,
                modifier = Modifier.padding(bottom = 40.dp)
            ) {
                Text(
                    text = "設定",
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "→",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
fun ConnectionDotsAnimation(
    showSuccessAnimation: Boolean,
    greenColor: Color,
    greenLight: Color
) {
    var leftPulse by remember { mutableStateOf(false) }
    var waveProgress by remember { mutableFloatStateOf(0f) }
    var rightPulse by remember { mutableStateOf(false) }

    // Success animation sequence
    LaunchedEffect(showSuccessAnimation) {
        if (showSuccessAnimation) {
            // Phase 1: Left pulse
            leftPulse = true
            delay(150)
            leftPulse = false

            // Phase 2: Wave travels
            delay(50)
            waveProgress = 1f

            // Phase 3: Right pulse (after wave arrives)
            delay(400)
            rightPulse = true
            delay(150)
            rightPulse = false

            // Reset
            delay(500)
            waveProgress = 0f
        }
    }

    // Animated values
    val leftScale by animateFloatAsState(
        targetValue = if (leftPulse) 1.3f else 1f,
        animationSpec = tween(150),
        label = "leftScale"
    )

    val leftGlowAlpha by animateFloatAsState(
        targetValue = if (leftPulse) 0.8f else 0.3f,
        animationSpec = tween(150),
        label = "leftGlowAlpha"
    )

    val animatedWaveProgress by animateFloatAsState(
        targetValue = waveProgress,
        animationSpec = tween(400, easing = EaseInOut),
        label = "waveProgress"
    )

    val rightScale by animateFloatAsState(
        targetValue = if (rightPulse) 1.3f else 1f,
        animationSpec = tween(150),
        label = "rightScale"
    )

    val rightGlowAlpha by animateFloatAsState(
        targetValue = if (rightPulse) 0.8f else 0.3f,
        animationSpec = tween(150),
        label = "rightGlowAlpha"
    )

    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
        modifier = Modifier.height(80.dp)
    ) {
        // Left dot
        Box(contentAlignment = Alignment.Center) {
            // Glow
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .scale(if (leftPulse) 1.5f else 1f)
                    .alpha(leftGlowAlpha)
                    .background(greenLight, CircleShape)
            )
            // Main dot
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .scale(leftScale)
                    .background(greenColor, CircleShape)
            )
        }

        // Connecting line with wave
        Box(
            modifier = Modifier
                .width(80.dp)
                .height(4.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            // Base line
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(greenLight.copy(alpha = 0.4f))
            )
            // Wave indicator
            if (showSuccessAnimation && animatedWaveProgress > 0f && animatedWaveProgress < 1f) {
                Box(
                    modifier = Modifier
                        .offset(x = (80 * animatedWaveProgress - 6).dp)
                        .size(12.dp)
                        .background(greenColor, CircleShape)
                )
            }
        }

        // Right dot
        Box(contentAlignment = Alignment.Center) {
            // Glow
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .scale(if (rightPulse) 1.5f else 1f)
                    .alpha(rightGlowAlpha)
                    .background(greenLight, CircleShape)
            )
            // Main dot
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .scale(rightScale)
                    .background(greenColor, CircleShape)
            )
        }
    }
}
