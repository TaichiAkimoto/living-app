import SwiftUI

struct SettingsView: View {
    let isInitialSetup: Bool

    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    @State private var name = ""
    @State private var emergencyContactName = ""
    @State private var emergencyContactEmail = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let firebaseService = FirebaseService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sumiBlack
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // ヘッダー
                        if isInitialSetup {
                            VStack(spacing: 12) {
                                Text("Living")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)

                                Text("生存確認アプリ")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        }

                        // 入力フォーム
                        VStack(spacing: 24) {
                            // 自分の名前
                            VStack(alignment: .leading, spacing: 8) {
                                Text("あなたの名前")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                TextField("", text: $name)
                                    .textFieldStyle(DarkTextFieldStyle())
                                    .autocorrectionDisabled()
                            }

                            Divider()
                                .background(Color.gray.opacity(0.3))

                            // 緊急連絡先セクション
                            VStack(alignment: .leading, spacing: 16) {
                                Text("緊急連絡先")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("連絡先の名前")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)

                                    TextField("", text: $emergencyContactName)
                                        .textFieldStyle(DarkTextFieldStyle())
                                        .autocorrectionDisabled()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("メールアドレス")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)

                                    TextField("", text: $emergencyContactEmail)
                                        .textFieldStyle(DarkTextFieldStyle())
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
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        // エラー表示
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
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
                            .background(isValid ? Color.checkInGreen : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
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
                        .foregroundColor(.white)
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
                    hasCompletedSetup = true
                    if !isInitialSetup {
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

// MARK: - Dark TextField Style
struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview("Initial Setup") {
    SettingsView(isInitialSetup: true)
}

#Preview("Settings") {
    SettingsView(isInitialSetup: false)
}
