import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // アプリ名
                Text("Living")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                // チェックインボタン
                Button(action: {
                    Task {
                        await viewModel.checkIn()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .semibold))
                        Text("確認する")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)

                // 最終確認時刻
                if let lastCheckIn = viewModel.lastCheckIn {
                    Text("最終確認: \(lastCheckIn.relativeString)")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }

                // 説明テキスト
                Text("2日間未確認で通知")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Spacer()

                // 設定ボタン
                Button(action: { showSettings = true }) {
                    HStack(spacing: 4) {
                        Text("設定")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)
            }

            // エラー表示
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color(.systemRed))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isInitialSetup: false)
        }
        .onAppear {
            viewModel.loadLastCheckIn()
        }
    }
}

// MARK: - Date Extension
extension Date {
    var relativeString: String {
        let interval = Date().timeIntervalSince(self)

        // 1分未満は「たった今」
        if interval < 60 {
            return "たった今"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    CheckInView()
}
