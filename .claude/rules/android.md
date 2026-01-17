---
paths: "android/**/*"
---

# Android 実装ガイド

## 技術スタック

| カテゴリ | 選択 |
|----------|------|
| UI | Jetpack Compose |
| 言語 | Kotlin |
| 最小SDK | 26 (Android 8.0) |
| アーキテクチャ | MVVM |

## UIデザイン

### カラー（iOS同等）
```kotlin
val SumiBlack = Color(0xFF1A1A1A)
val CheckInGreen = Color(0xFF22C55E)
val TextWhite = Color(0xFFFFFFFF)
```

### メイン画面
```kotlin
@Composable
fun CheckInScreen(viewModel: CheckInViewModel) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(SumiBlack),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CheckInButton(onClick = { viewModel.checkIn() })
        Spacer(modifier = Modifier.height(24.dp))
        Text("最終確認: ${viewModel.lastCheckIn}", color = TextWhite)
    }
}
```

## deviceId 永続化

```kotlin
// EncryptedSharedPreferences使用
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class DeviceIdManager(context: Context) {
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

    fun getOrCreateDeviceId(): String {
        return prefs.getString("deviceId", null) ?: run {
            val newId = UUID.randomUUID().toString()
            prefs.edit().putString("deviceId", newId).apply()
            newId
        }
    }
}
```

## Firebase連携

```kotlin
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class UserRepository {
    private val db = Firebase.firestore

    suspend fun updateCheckIn(deviceId: String) {
        db.collection("users").document(deviceId)
            .update(
                mapOf(
                    "lastCheckIn" to FieldValue.serverTimestamp(),
                    "notified" to false
                )
            )
            .await()
    }
}
```

## 依存関係（build.gradle.kts）

```kotlin
dependencies {
    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-firestore-ktx")

    // Security
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
}
```
