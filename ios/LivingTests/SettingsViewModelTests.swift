import XCTest
@testable import Living

final class SettingsViewModelTests: XCTestCase {

    var viewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 変更検出テスト

    func testHasChanges_initialState_returnsFalse() {
        // 初期状態では変更なし
        XCTAssertFalse(viewModel.hasChanges)
    }

    func testHasChanges_nameChanged_returnsTrue() {
        // 名前を変更したら変更あり
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"
        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChanges_emergencyContactNameChanged_returnsTrue() {
        // 緊急連絡先名を変更したら変更あり
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.emergencyContactName = "春子"
        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChanges_emergencyContactEmailChanged_returnsTrue() {
        // メールアドレスを変更したら変更あり
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.emergencyContactEmail = "haruko@example.com"
        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChanges_whitespaceOnly_returnsFalse() {
        // 空白のみの変更は変更なし扱い
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "太郎  " // 末尾に空白
        XCTAssertFalse(viewModel.hasChanges)
    }

    func testHasChanges_multipleFieldsChanged_returnsTrue() {
        // 複数フィールド変更で変更あり
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"
        viewModel.emergencyContactEmail = "jiro@example.com"
        XCTAssertTrue(viewModel.hasChanges)
    }

    func testHasChanges_changedThenReverted_returnsFalse() {
        // 変更後に元に戻したら変更なし
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"
        viewModel.name = "太郎"
        XCTAssertFalse(viewModel.hasChanges)
    }

    // MARK: - バリデーションテスト

    func testIsValid_allFieldsValid_returnsTrue() {
        // 全フィールド有効
        viewModel.name = "太郎"
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertTrue(viewModel.isValid)
    }

    func testIsValid_nameEmpty_returnsFalse() {
        // 名前が空
        viewModel.name = ""
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValid_nameWhitespaceOnly_returnsFalse() {
        // 名前が空白のみ
        viewModel.name = "   "
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValid_emergencyContactNameEmpty_returnsFalse() {
        // 緊急連絡先名が空
        viewModel.name = "太郎"
        viewModel.emergencyContactName = ""
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValid_emailWithoutAtSign_returnsFalse() {
        // @がないメールアドレス
        viewModel.name = "太郎"
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanakoexample.com"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValid_nameTooLong_returnsFalse() {
        // 名前が50文字超
        viewModel.name = String(repeating: "あ", count: 51)
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsValid_nameExactly50Characters_returnsTrue() {
        // 名前がちょうど50文字
        viewModel.name = String(repeating: "あ", count: 50)
        viewModel.emergencyContactName = "花子"
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertTrue(viewModel.isValid)
    }

    func testIsValid_emergencyContactNameTooLong_returnsFalse() {
        // 緊急連絡先名が50文字超
        viewModel.name = "太郎"
        viewModel.emergencyContactName = String(repeating: "あ", count: 51)
        viewModel.emergencyContactEmail = "hanako@example.com"
        XCTAssertFalse(viewModel.isValid)
    }

    // MARK: - リセット機能テスト

    func testReset_restoresOriginalValues() {
        // リセットで元のデータに戻る
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"
        viewModel.emergencyContactName = "春子"
        viewModel.emergencyContactEmail = "jiro@example.com"

        viewModel.reset()

        XCTAssertEqual(viewModel.name, "太郎")
        XCTAssertEqual(viewModel.emergencyContactName, "花子")
        XCTAssertEqual(viewModel.emergencyContactEmail, "hanako@example.com")
    }

    func testReset_afterReset_hasChangesIsFalse() {
        // リセット後は変更なし
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"

        viewModel.reset()

        XCTAssertFalse(viewModel.hasChanges)
    }

    // MARK: - キャンセル処理テスト

    func testCancel_noChanges_returnsFalse() {
        // 変更なしの場合はfalse（ダイアログ不要）
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        XCTAssertFalse(viewModel.cancel())
    }

    func testCancel_hasChanges_returnsTrue() {
        // 変更ありの場合はtrue（ダイアログ表示）
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"
        XCTAssertTrue(viewModel.cancel())
    }

    // MARK: - loadOriginalData テスト

    func testLoadOriginalData_setsNameFields() {
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        XCTAssertEqual(viewModel.name, "太郎")
        XCTAssertEqual(viewModel.emergencyContactName, "花子")
        XCTAssertEqual(viewModel.emergencyContactEmail, "hanako@example.com")
    }

    func testLoadOriginalData_updatesOriginalValues() {
        viewModel.loadOriginalData(name: "太郎", emergencyContactName: "花子", emergencyContactEmail: "hanako@example.com")
        viewModel.name = "次郎"

        // 再度読み込み
        viewModel.loadOriginalData(name: "三郎", emergencyContactName: "春子", emergencyContactEmail: "haruko@example.com")

        XCTAssertEqual(viewModel.name, "三郎")
        XCTAssertFalse(viewModel.hasChanges) // 新しい元データと一致
    }
}
