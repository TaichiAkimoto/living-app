package com.living.app.ui

import android.text.format.DateUtils
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.living.app.data.PreferencesManager
import com.living.app.data.UserRepository
import com.living.app.ui.theme.CheckInGreen
import com.living.app.ui.theme.SumiBlack
import com.living.app.ui.theme.TextGray
import com.living.app.ui.theme.TextWhite
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.Date

@Composable
fun CheckInScreen(
    onSettingsClick: () -> Unit
) {
    val context = LocalContext.current
    val preferencesManager = remember { PreferencesManager(context) }
    val repository = remember { UserRepository(preferencesManager.deviceId) }

    var lastCheckIn by remember { mutableStateOf<Date?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var isAnimating by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    val scale by animateFloatAsState(
        targetValue = if (isAnimating) 1.1f else 1f,
        animationSpec = tween(durationMillis = 200),
        label = "scale"
    )

    LaunchedEffect(Unit) {
        lastCheckIn = repository.getLastCheckIn()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SumiBlack)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.weight(1f))

            // チェックインボタン
            Button(
                onClick = {
                    scope.launch {
                        isLoading = true
                        errorMessage = null
                        try {
                            repository.updateCheckIn()
                            lastCheckIn = Date()
                            isAnimating = true
                            delay(300)
                            isAnimating = false
                        } catch (e: Exception) {
                            errorMessage = "チェックインに失敗しました"
                        }
                        isLoading = false
                    }
                },
                modifier = Modifier
                    .size(200.dp)
                    .scale(scale)
                    .shadow(
                        elevation = if (isAnimating) 30.dp else 20.dp,
                        shape = CircleShape,
                        spotColor = CheckInGreen.copy(alpha = 0.5f)
                    ),
                shape = CircleShape,
                colors = ButtonDefaults.buttonColors(containerColor = CheckInGreen),
                enabled = !isLoading
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(
                            color = TextWhite,
                            modifier = Modifier.size(48.dp)
                        )
                    } else {
                        Text(
                            text = "✓",
                            fontSize = 48.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextWhite
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "チェックイン",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = TextWhite
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // 説明テキスト
            Text(
                text = "2日間サインインがない場合",
                fontSize = 14.sp,
                color = TextGray
            )
            Text(
                text = "緊急連絡先にメールが届きます",
                fontSize = 14.sp,
                color = TextGray
            )

            Spacer(modifier = Modifier.height(16.dp))

            // 最終確認時刻
            lastCheckIn?.let { date ->
                val relativeTime = DateUtils.getRelativeTimeSpanString(
                    date.time,
                    System.currentTimeMillis(),
                    DateUtils.MINUTE_IN_MILLIS
                )
                Text(
                    text = "最終確認: $relativeTime",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = TextWhite
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // エラー表示
            errorMessage?.let { error ->
                Surface(
                    color = Color.Red.copy(alpha = 0.8f),
                    shape = MaterialTheme.shapes.small
                ) {
                    Text(
                        text = error,
                        fontSize = 14.sp,
                        color = TextWhite,
                        modifier = Modifier.padding(16.dp)
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))
            }

            // 設定ボタン
            TextButton(
                onClick = onSettingsClick,
                modifier = Modifier.padding(bottom = 40.dp)
            ) {
                Text(
                    text = "⚙️ 設定",
                    fontSize = 16.sp,
                    color = TextGray
                )
            }
        }
    }
}
