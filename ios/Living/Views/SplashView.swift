import SwiftUI

struct SplashView: View {
    @State private var showLeftDot = false
    @State private var lineProgress: CGFloat = 0
    @State private var showRightDot = false
    @State private var leftGlow = false
    @State private var rightGlow = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Two dots animation
                HStack(spacing: 0) {
                    // Left dot with glow
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .scaleEffect(leftGlow ? 1.2 : 1.0)
                            .opacity(showLeftDot ? (leftGlow ? 0.5 : 0.3) : 0)

                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                            .scaleEffect(showLeftDot ? 1 : 0)
                            .opacity(showLeftDot ? 1 : 0)
                    }

                    // Connecting line
                    Rectangle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 100 * lineProgress, height: 4)

                    // Right dot with glow
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .scaleEffect(rightGlow ? 1.2 : 1.0)
                            .opacity(showRightDot ? (rightGlow ? 0.5 : 0.3) : 0)

                        Circle()
                            .fill(Color.green)
                            .frame(width: 40, height: 40)
                            .scaleEffect(showRightDot ? 1 : 0)
                            .opacity(showRightDot ? 1 : 0)
                    }
                }

                Spacer()

                // App name
                Text("生きろ。")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.primary)
                    .opacity(showRightDot ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Phase 1: Show left dot
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showLeftDot = true
        }

        // Phase 2: Extend line
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.6)) {
                lineProgress = 1
            }
        }

        // Phase 3: Show right dot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showRightDot = true
            }
        }

        // Phase 4: Glow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                leftGlow = true
                rightGlow = true
            }
        }
    }
}

#Preview {
    SplashView()
}
