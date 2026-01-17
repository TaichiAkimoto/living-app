import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @State private var showSettings = false
    @State private var showSuccessAnimation = false
    @State private var leftPulse = false
    @State private var wavePosition: CGFloat = 0
    @State private var rightPulse = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Two dots motif
                ConnectionDotsView(
                    showSuccessAnimation: showSuccessAnimation,
                    leftPulse: leftPulse,
                    wavePosition: wavePosition,
                    rightPulse: rightPulse
                )
                .frame(height: 80)

                // App name
                Text("生きろ。")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                // Check-in button
                Button(action: {
                    Task {
                        await viewModel.checkIn()
                        if viewModel.errorMessage == nil {
                            playSuccessAnimation()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                            Text("確認する")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)

                // Last check-in time
                if let lastCheckIn = viewModel.lastCheckIn {
                    Text("最終確認: \(lastCheckIn.relativeString)")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                }

                // Description
                Text("2日間未確認で通知")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Spacer()

                // Settings button
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

            // Error display
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

    private func playSuccessAnimation() {
        // Reset
        showSuccessAnimation = false
        leftPulse = false
        wavePosition = 0
        rightPulse = false

        // Start animation
        showSuccessAnimation = true

        // Phase 1: Left dot pulse
        withAnimation(.easeOut(duration: 0.15)) {
            leftPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.15)) {
                leftPulse = false
            }
        }

        // Phase 2: Wave travels
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                wavePosition = 1
            }
        }

        // Phase 3: Right dot pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.15)) {
                rightPulse = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeIn(duration: 0.15)) {
                rightPulse = false
            }
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSuccessAnimation = false
            wavePosition = 0
        }
    }
}

// MARK: - Connection Dots View
struct ConnectionDotsView: View {
    let showSuccessAnimation: Bool
    let leftPulse: Bool
    let wavePosition: CGFloat
    let rightPulse: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Left dot
            ZStack {
                // Glow
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(leftPulse ? 1.5 : 1.0)
                    .opacity(leftPulse ? 0.8 : 0.3)

                // Main dot
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)
                    .scaleEffect(leftPulse ? 1.2 : 1.0)
            }

            // Connecting line with wave
            ZStack {
                // Base line
                Rectangle()
                    .fill(Color.green.opacity(0.4))
                    .frame(width: 80, height: 3)

                // Wave indicator
                if showSuccessAnimation {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .offset(x: -40 + (80 * wavePosition))
                        .opacity(wavePosition > 0 && wavePosition < 1 ? 1 : 0)
                }
            }

            // Right dot
            ZStack {
                // Glow
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(rightPulse ? 1.5 : 1.0)
                    .opacity(rightPulse ? 0.8 : 0.3)

                // Main dot
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)
                    .scaleEffect(rightPulse ? 1.2 : 1.0)
            }
        }
    }
}

// MARK: - Date Extension
extension Date {
    var relativeString: String {
        let interval = Date().timeIntervalSince(self)

        // Less than 1 minute
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
