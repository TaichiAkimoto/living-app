package com.living.app

import android.app.Application
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

enum class AuthState {
    Loading,
    Ready,
    Failed
}

class LivingApplication : Application() {
    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private val _authState = MutableStateFlow(AuthState.Loading)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private var retryCount = 0
    private val maxRetries = 3

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)

        // Anonymous Auth でサインイン
        attemptAuth()
    }

    fun retryAuth() {
        retryCount = 0
        _authState.value = AuthState.Loading
        attemptAuth()
    }

    private fun attemptAuth() {
        val auth = Firebase.auth

        // 既にサインイン済みの場合は成功
        if (auth.currentUser != null) {
            _authState.value = AuthState.Ready
            return
        }

        applicationScope.launch {
            try {
                auth.signInAnonymously().await()
                _authState.value = AuthState.Ready
            } catch (e: Exception) {
                e.printStackTrace()
                retryCount++

                if (retryCount < maxRetries) {
                    // Exponential backoff: 1s, 2s, 4s
                    val delayMs = (1000L * (1 shl (retryCount - 1)))
                    delay(delayMs)
                    attemptAuth()
                } else {
                    // All retries failed
                    _authState.value = AuthState.Failed
                }
            }
        }
    }

    companion object {
        private var instance: LivingApplication? = null

        fun getInstance(): LivingApplication {
            return instance ?: throw IllegalStateException("Application not initialized")
        }
    }

    init {
        instance = this
    }
}
