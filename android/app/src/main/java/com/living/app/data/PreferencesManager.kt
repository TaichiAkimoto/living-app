package com.living.app.data

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.util.UUID

class PreferencesManager(context: Context) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "living_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    var hasCompletedSetup: Boolean
        get() = prefs.getBoolean(KEY_HAS_COMPLETED_SETUP, false)
        set(value) = prefs.edit().putBoolean(KEY_HAS_COMPLETED_SETUP, value).apply()

    val deviceId: String
        get() = prefs.getString(KEY_DEVICE_ID, null) ?: run {
            val newId = UUID.randomUUID().toString()
            prefs.edit().putString(KEY_DEVICE_ID, newId).apply()
            newId
        }

    companion object {
        private const val KEY_HAS_COMPLETED_SETUP = "has_completed_setup"
        private const val KEY_DEVICE_ID = "device_id"
    }
}
