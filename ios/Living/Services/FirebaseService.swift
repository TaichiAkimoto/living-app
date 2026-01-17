import Foundation
import FirebaseFirestore
import KeychainAccess

final class FirebaseService {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()
    private let keychain = Keychain(service: "com.living.app")

    private init() {}

    // MARK: - Device ID

    /// デバイスIDを取得または生成（Keychainに永続化）
    var deviceId: String {
        if let existing = keychain["deviceId"] {
            return existing
        }
        let newId = UUID().uuidString
        keychain["deviceId"] = newId
        return newId
    }

    // MARK: - User Data

    /// ユーザーデータを保存
    func saveUserData(_ userData: UserData) async throws {
        var data = userData.toFirestore()
        data["createdAt"] = FieldValue.serverTimestamp()
        data["lastCheckIn"] = FieldValue.serverTimestamp()
        data["notified"] = false

        try await db.collection("users").document(deviceId).setData(data, merge: true)
    }

    /// ユーザーデータを取得
    func getUserData() async -> UserData? {
        do {
            let document = try await db.collection("users").document(deviceId).getDocument()
            return UserData(from: document)
        } catch {
            print("Error getting user data: \(error)")
            return nil
        }
    }

    // MARK: - Check In

    /// チェックインを記録
    func updateCheckIn() async throws {
        try await db.collection("users").document(deviceId).updateData([
            "lastCheckIn": FieldValue.serverTimestamp(),
            "notified": false
        ])
    }

    /// 最終チェックイン時刻を取得
    func getLastCheckIn() async -> Date? {
        do {
            let document = try await db.collection("users").document(deviceId).getDocument()
            guard let data = document.data(),
                  let timestamp = data["lastCheckIn"] as? Timestamp else {
                return nil
            }
            return timestamp.dateValue()
        } catch {
            print("Error getting last check-in: \(error)")
            return nil
        }
    }
}
