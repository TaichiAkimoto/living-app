import SwiftUI

struct AuthErrorView: View {
    let onRetry: () -> Void
    @State private var isRetrying = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Two dots (gray, disconnected look)
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 32, height: 32)

                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 80, height: 3)

                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 32, height: 32)
                }

                // Error message
                VStack(spacing: 8) {
                    Text("接続できませんでした")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("インターネット接続を確認してください")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Retry button
                Button(action: {
                    isRetrying = true
                    onRetry()
                }) {
                    HStack(spacing: 8) {
                        if isRetrying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text("再試行する")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isRetrying)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    AuthErrorView(onRetry: {})
}
