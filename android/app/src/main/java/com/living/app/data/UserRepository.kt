package com.living.app.data

import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await
import java.util.Date

data class UserData(
    val name: String = "",
    val emergencyContactName: String = "",
    val emergencyContactEmail: String = "",
    val lastCheckIn: Date? = null,
    val notified: Boolean = false
)

class UserRepository(private val deviceId: String) {
    private val db = FirebaseFirestore.getInstance()
    private val userRef = db.collection("users").document(deviceId)

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
        return try {
            val snapshot = userRef.get().await()
            snapshot.getTimestamp("lastCheckIn")?.toDate()
        } catch (e: Exception) {
            null
        }
    }
}
