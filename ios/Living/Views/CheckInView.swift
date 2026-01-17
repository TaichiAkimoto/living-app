import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @State private var showSettings = false
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // 背景
            Color.sumiBlack
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // チェックインボタン
                Button(action: {
                    Task {
                        await viewModel.checkIn()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = false
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.checkInGreen)
                            .frame(width: 200, height: 200)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .shadow(color: Color.checkInGreen.opacity(0.5), radius: isAnimating ? 30 : 20)

                        VStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)

                            Text("チェックイン")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(viewModel.isLoading)

                // 説明テキスト
                VStack(spacing: 8) {
                    Text("2日間サインインがない場合")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text("緊急連絡先にメールが届きます")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                // 最終確認時刻
                if let lastCheckIn = viewModel.lastCheckIn {
                    Text("最終確認: \(lastCheckIn.relativeString)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                // 設定ボタン
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }

            // エラー表示
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
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

// MARK: - Color Extensions
extension Color {
    static let sumiBlack = Color(hex: "1a1a1a")
    static let checkInGreen = Color(hex: "22c55e")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extension
extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    CheckInView()
}
