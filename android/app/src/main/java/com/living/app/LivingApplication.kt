package com.living.app

import android.app.Application
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class LivingApplication : Application() {
    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)

        // Anonymous Auth でサインイン
        signInAnonymously()
    }

    private fun signInAnonymously() {
        val auth = Firebase.auth

        // 既にサインイン済みの場合はスキップ
        if (auth.currentUser != null) {
            return
        }

        applicationScope.launch {
            try {
                auth.signInAnonymously().await()
            } catch (e: Exception) {
                // エラーログ（次回起動時に再試行）
                e.printStackTrace()
            }
        }
    }
}
