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

        setContent {
            LivingTheme {
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    var showSplash by remember { mutableStateOf(true) }
                    var hasSeenOnboarding by remember {
                        mutableStateOf(preferencesManager.hasSeenOnboarding)
                    }
                    var hasCompletedSetup by remember {
                        mutableStateOf(preferencesManager.hasCompletedSetup)
                    }
                    var showSettings by remember { mutableStateOf(false) }

                    // Splash timer
                    LaunchedEffect(Unit) {
                        delay(2500)
                        showSplash = false
                    }

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
