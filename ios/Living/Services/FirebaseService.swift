import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseService {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Device ID (Auth UID)

    /// デバイスID（Anonymous Auth UID）を取得
    /// Firestoreルールで auth.uid == deviceId を要求するため、Auth UIDを使用
    var deviceId: String? {
        Auth.auth().currentUser?.uid
    }

    /// デバイスIDを取得（必須版）
    /// - Throws: 未認証の場合にエラー
    private func requireDeviceId() throws -> String {
        guard let id = deviceId else {
            throw FirebaseServiceError.notAuthenticated
        }
        return id
    }

    // MARK: - User Data

    /// ユーザーデータを保存
    func saveUserData(_ userData: UserData) async throws {
        let id = try requireDeviceId()

        var data = userData.toFirestore()
        data["createdAt"] = FieldValue.serverTimestamp()
        data["lastCheckIn"] = FieldValue.serverTimestamp()
        data["notified"] = false

        try await db.collection("users").document(id).setData(data, merge: true)
    }

    /// ユーザーデータを取得
    func getUserData() async -> UserData? {
        guard let id = deviceId else { return nil }

        do {
            let document = try await db.collection("users").document(id).getDocument()
            return UserData(from: document)
        } catch {
            print("Error getting user data: \(error)")
            return nil
        }
    }

    // MARK: - Check In

    /// チェックインを記録
    func updateCheckIn() async throws {
        let id = try requireDeviceId()

        try await db.collection("users").document(id).updateData([
            "lastCheckIn": FieldValue.serverTimestamp(),
            "notified": false
        ])
    }

    /// 最終チェックイン時刻を取得
    func getLastCheckIn() async -> Date? {
        guard let id = deviceId else { return nil }

        do {
            let document = try await db.collection("users").document(id).getDocument()
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

// MARK: - Errors

enum FirebaseServiceError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please wait for authentication to complete."
        }
    }
}
