package com.living.app

import android.app.Application
import com.google.firebase.FirebaseApp

class LivingApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
    }
}
