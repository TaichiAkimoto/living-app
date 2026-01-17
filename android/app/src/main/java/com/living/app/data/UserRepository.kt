package com.living.app.data

import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.tasks.await
import java.util.Date

data class UserData(
    val name: String = "",
    val emergencyContactName: String = "",
    val emergencyContactEmail: String = "",
    val lastCheckIn: Date? = null,
    val notified: Boolean = false
)

/**
 * UserRepository
 *
 * Anonymous Auth UID を deviceId として使用し、Firestore にアクセスする。
 * Firestore ルールで auth.uid == deviceId を要求するため、Auth UID を使用。
 */
class UserRepository {
    private val db = FirebaseFirestore.getInstance()

    /**
     * 認証済みの UID を取得
     * @return UID、未認証の場合は null
     */
    private val deviceId: String?
        get() = Firebase.auth.currentUser?.uid

    /**
     * 認証済みの UID を取得（必須版）
     * @throws IllegalStateException 未認証の場合
     */
    private fun requireDeviceId(): String {
        return deviceId ?: throw IllegalStateException("Not authenticated. Please wait for authentication to complete.")
    }

    private val userRef
        get() = db.collection("users").document(requireDeviceId())

    /**
     * 認証状態を確認
     */
    fun isAuthenticated(): Boolean = deviceId != null

    suspend fun saveUserData(userData: UserData) {
        val data = hashMapOf(
            "name" to userData.name,
            "emergencyContactName" to userData.emergencyContactName,
            "emergencyContactEmail" to userData.emergencyContactEmail,
            "lastCheckIn" to FieldValue.serverTimestamp(),
            "createdAt" to FieldValue.serverTimestamp(),
            "notified" to false
        )
        userRef.set(data).await()
    }

    suspend fun getUserData(): UserData? {
        if (!isAuthenticated()) return null

        return try {
            val snapshot = userRef.get().await()
            if (snapshot.exists()) {
                UserData(
                    name = snapshot.getString("name") ?: "",
                    emergencyContactName = snapshot.getString("emergencyContactName") ?: "",
                    emergencyContactEmail = snapshot.getString("emergencyContactEmail") ?: "",
                    lastCheckIn = snapshot.getTimestamp("lastCheckIn")?.toDate(),
                    notified = snapshot.getBoolean("notified") ?: false
                )
            } else null
        } catch (e: Exception) {
            null
        }
    }

    suspend fun updateCheckIn() {
        userRef.update(
            mapOf(
                "lastCheckIn" to FieldValue.serverTimestamp(),
                "notified" to false
            )
        ).await()
    }

    suspend fun getLastCheckIn(): Date? {
        if (!isAuthenticated()) return null

        return try {
            val snapshot = userRef.get().await()
            snapshot.getTimestamp("lastCheckIn")?.toDate()
        } catch (e: Exception) {
            null
        }
    }
}
