import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "毎日タップするだけ",
            description: "緑のボタンを1日1回タップして\n生存確認をしましょう",
            systemImage: "hand.tap.fill",
            color: .green
        ),
        OnboardingPage(
            title: "2日間忘れると通知",
            description: "チェックインを2日間忘れると\n緊急連絡先に通知が届きます",
            systemImage: "bell.badge.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "大切な人に届く",
            description: "あなたの安否を見守る人に\nメールで知らせます",
            systemImage: "person.2.fill",
            color: .blue
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("スキップ") {
                        print("Skip tapped")
                        completeOnboarding()
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 20)

                // Next/Start button
                Button {
                    print("Button tapped, currentPage: \(currentPage), pages.count: \(pages.count)")
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        print("Calling completeOnboarding")
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "次へ" : "はじめる")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        onComplete()
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 160, height: 160)

                Image(systemName: page.systemImage)
                    .font(.system(size: 64))
                    .foregroundColor(page.color)
            }

            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            // Description
            Text(page.description)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
