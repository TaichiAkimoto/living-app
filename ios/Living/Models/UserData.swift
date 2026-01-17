import Foundation
import FirebaseFirestore

struct UserData: Codable {
    let name: String
    let emergencyContactName: String
    let emergencyContactEmail: String
    var lastCheckIn: Date?
    var createdAt: Date?
    var notified: Bool?

    init(
        name: String,
        emergencyContactName: String,
        emergencyContactEmail: String,
        lastCheckIn: Date? = nil,
        createdAt: Date? = nil,
        notified: Bool? = false
    ) {
        self.name = name
        self.emergencyContactName = emergencyContactName
        self.emergencyContactEmail = emergencyContactEmail
        self.lastCheckIn = lastCheckIn
        self.createdAt = createdAt
        self.notified = notified
    }
}

extension UserData {
    /// Firestoreに保存するための辞書
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "emergencyContactName": emergencyContactName,
            "emergencyContactEmail": emergencyContactEmail,
            "notified": notified ?? false
        ]

        if let lastCheckIn = lastCheckIn {
            data["lastCheckIn"] = Timestamp(date: lastCheckIn)
        }

        if let createdAt = createdAt {
            data["createdAt"] = Timestamp(date: createdAt)
        }

        return data
    }

    /// Firestoreからの変換
    init?(from document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

        guard let name = data["name"] as? String,
              let emergencyContactName = data["emergencyContactName"] as? String,
              let emergencyContactEmail = data["emergencyContactEmail"] as? String else {
            return nil
        }

        self.name = name
        self.emergencyContactName = emergencyContactName
        self.emergencyContactEmail = emergencyContactEmail
        self.lastCheckIn = (data["lastCheckIn"] as? Timestamp)?.dateValue()
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        self.notified = data["notified"] as? Bool ?? false
    }
}
