package com.living.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.living.app.data.PreferencesManager
import com.living.app.ui.CheckInScreen
import com.living.app.ui.SettingsScreen
import com.living.app.ui.theme.LivingTheme
import com.living.app.ui.theme.SumiBlack

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val preferencesManager = PreferencesManager(this)

        setContent {
            LivingTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = SumiBlack
                ) {
                    var hasCompletedSetup by remember {
                        mutableStateOf(preferencesManager.hasCompletedSetup)
                    }
                    var showSettings by remember { mutableStateOf(false) }

                    if (!hasCompletedSetup || showSettings) {
                        SettingsScreen(
                            isInitialSetup = !hasCompletedSetup,
                            onComplete = {
                                hasCompletedSetup = true
                                preferencesManager.hasCompletedSetup = true
                                showSettings = false
                            },
                            onDismiss = { showSettings = false }
                        )
                    } else {
                        CheckInScreen(
                            onSettingsClick = { showSettings = true }
                        )
                    }
                }
            }
        }
    }
}
