import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var name: String = ""
    @Published var emergencyContactName: String = ""
    @Published var emergencyContactEmail: String = ""

    // MARK: - Private Properties

    private var originalName: String = ""
    private var originalEmergencyContactName: String = ""
    private var originalEmergencyContactEmail: String = ""

    // MARK: - Computed Properties

    /// 変更検出（Dirty State）
    /// trim後の値で比較し、空白のみの変更は変更なし扱い
    var hasChanges: Bool {
        name.trimmingCharacters(in: .whitespaces) != originalName.trimmingCharacters(in: .whitespaces) ||
        emergencyContactName.trimmingCharacters(in: .whitespaces) != originalEmergencyContactName.trimmingCharacters(in: .whitespaces) ||
        emergencyContactEmail.trimmingCharacters(in: .whitespaces) != originalEmergencyContactEmail.trimmingCharacters(in: .whitespaces)
    }

    /// バリデーション
    /// - 各フィールドが空でない（trimした後）
    /// - 名前と緊急連絡先名は50文字以内
    /// - メールアドレスに@が含まれる
    var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmergencyContactName = emergencyContactName.trimmingCharacters(in: .whitespaces)

        return !trimmedName.isEmpty &&
               !trimmedEmergencyContactName.isEmpty &&
               emergencyContactEmail.contains("@") &&
               name.count <= 50 &&
               emergencyContactName.count <= 50
    }

    // MARK: - Methods

    /// 元データを読み込み、現在の値と元データの両方に設定
    /// - Parameters:
    ///   - name: ユーザーの名前
    ///   - emergencyContactName: 緊急連絡先の名前
    ///   - emergencyContactEmail: 緊急連絡先のメールアドレス
    func loadOriginalData(name: String, emergencyContactName: String, emergencyContactEmail: String) {
        self.name = name
        self.emergencyContactName = emergencyContactName
        self.emergencyContactEmail = emergencyContactEmail

        self.originalName = name
        self.originalEmergencyContactName = emergencyContactName
        self.originalEmergencyContactEmail = emergencyContactEmail
    }

    /// キャンセル処理
    /// - Returns: 変更があった場合はtrue（ダイアログ表示が必要）、変更がない場合はfalse
    func cancel() -> Bool {
        return hasChanges
    }

    /// 元データに戻す
    func reset() {
        name = originalName
        emergencyContactName = originalEmergencyContactName
        emergencyContactEmail = originalEmergencyContactEmail
    }
}
