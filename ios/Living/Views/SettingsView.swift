import SwiftUI

struct SettingsView: View {
    let isInitialSetup: Bool
    var onComplete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emergencyContactName = ""
    @State private var emergencyContactEmail = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let firebaseService = FirebaseService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // ヘッダー
                        if isInitialSetup {
                            VStack(spacing: 12) {
                                Text("生きろ。")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.primary)

                                Text("生存確認アプリ")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 40)
                        }

                        // 入力フォーム
                        VStack(spacing: 24) {
                            // 自分の名前
                            VStack(alignment: .leading, spacing: 8) {
                                Text("あなたの名前")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)

                                TextField("", text: $name)
                                    .textFieldStyle(SystemTextFieldStyle())
                                    .autocorrectionDisabled()
                            }

                            Divider()

                            // 緊急連絡先セクション
                            VStack(alignment: .leading, spacing: 16) {
                                Text("緊急連絡先")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.primary)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("連絡先の名前")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)

                                    TextField("", text: $emergencyContactName)
                                        .textFieldStyle(SystemTextFieldStyle())
                                        .autocorrectionDisabled()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("メールアドレス")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)

                                    TextField("", text: $emergencyContactEmail)
                                        .textFieldStyle(SystemTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // 説明
                        Text("2日間チェックインがない場合、\n緊急連絡先にメールが送信されます")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        // エラー表示
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.systemRed))
                                .padding()
                        }

                        // 保存ボタン
                        Button(action: save) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isInitialSetup ? "始める" : "保存")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isValid ? Color.accentColor : Color(.systemGray3))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!isValid || isLoading)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isInitialSetup {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("閉じる") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !emergencyContactName.trimmingCharacters(in: .whitespaces).isEmpty &&
        emergencyContactEmail.contains("@") &&
        name.count <= 50 &&
        emergencyContactName.count <= 50
    }

    private func loadExistingData() {
        Task {
            if let userData = await firebaseService.getUserData() {
                await MainActor.run {
                    name = userData.name
                    emergencyContactName = userData.emergencyContactName
                    emergencyContactEmail = userData.emergencyContactEmail
                }
            }
        }
    }

    private func save() {
        guard isValid else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let userData = UserData(
                    name: name.trimmingCharacters(in: .whitespaces),
                    emergencyContactName: emergencyContactName.trimmingCharacters(in: .whitespaces),
                    emergencyContactEmail: emergencyContactEmail.trimmingCharacters(in: .whitespaces)
                )

                try await firebaseService.saveUserData(userData)

                await MainActor.run {
                    isLoading = false
                    if isInitialSetup {
                        onComplete?()
                    } else {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "保存に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - System TextField Style
struct SystemTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("Initial Setup") {
    SettingsView(isInitialSetup: true)
}

#Preview("Settings") {
    SettingsView(isInitialSetup: false)
}
