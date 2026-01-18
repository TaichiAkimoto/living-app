package com.living.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.living.app.data.PreferencesManager
import com.living.app.ui.AuthErrorScreen
import com.living.app.ui.CheckInScreen
import com.living.app.ui.OnboardingScreen
import com.living.app.ui.SettingsScreen
import com.living.app.ui.SplashScreen
import com.living.app.ui.theme.LivingTheme
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val preferencesManager = PreferencesManager(this)
        val app = LivingApplication.getInstance()

        setContent {
            LivingTheme {
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    var splashMinTimePassed by remember { mutableStateOf(false) }
                    var hasSeenOnboarding by remember {
                        mutableStateOf(preferencesManager.hasSeenOnboarding)
                    }
                    var hasCompletedSetup by remember {
                        mutableStateOf(preferencesManager.hasCompletedSetup)
                    }
                    var showSettings by remember { mutableStateOf(false) }

                    val authState by app.authState.collectAsState()

                    // Minimum splash time (2 seconds)
                    LaunchedEffect(Unit) {
                        delay(2000)
                        splashMinTimePassed = true
                    }

                    // Show splash until min time passed AND auth is not loading
                    val showSplash = !splashMinTimePassed || authState == AuthState.Loading

                    // Screen navigation
                    AnimatedVisibility(
                        visible = showSplash,
                        enter = fadeIn(),
                        exit = fadeOut()
                    ) {
                        SplashScreen()
                    }

                    AnimatedVisibility(
                        visible = !showSplash,
                        enter = fadeIn(),
                        exit = fadeOut()
                    ) {
                        when {
                            authState == AuthState.Failed -> {
                                AuthErrorScreen(
                                    onRetry = { app.retryAuth() }
                                )
                            }
                            !hasSeenOnboarding -> {
                                OnboardingScreen(
                                    onComplete = {
                                        hasSeenOnboarding = true
                                        preferencesManager.hasSeenOnboarding = true
                                    }
                                )
                            }
                            !hasCompletedSetup || showSettings -> {
                                SettingsScreen(
                                    isInitialSetup = !hasCompletedSetup,
                                    onComplete = {
                                        hasCompletedSetup = true
                                        preferencesManager.hasCompletedSetup = true
                                        showSettings = false
                                    },
                                    onDismiss = { showSettings = false }
                                )
                            }
                            else -> {
                                CheckInScreen(
                                    onSettingsClick = { showSettings = true }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
