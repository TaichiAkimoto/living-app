import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LivingApp: App {
    @StateObject private var appState = AppState()
    @State private var showSplash = true
    @State private var splashMinTimePassed = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                if showSplash || !splashMinTimePassed {
                    SplashView()
                } else if appState.authFailed {
                    AuthErrorView(onRetry: {
                        appState.retryAuth()
                    })
                } else if appState.isAuthReady {
                    if !appState.hasSeenOnboarding {
                        OnboardingView(onComplete: {
                            print("onComplete called")
                            appState.completeOnboarding()
                        })
                    } else if appState.hasCompletedSetup {
                        CheckInView()
                    } else {
                        SettingsView(isInitialSetup: true, onComplete: {
                            appState.completeSetup()
                        })
                    }
                } else {
                    // Auth loading state
                    ProgressView("接続中...")
                }
            }
            .onAppear {
                // Start auth flow immediately
                appState.setupAuth()

                // Minimum splash display time (2 seconds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        splashMinTimePassed = true
                        if appState.isAuthReady || appState.authFailed {
                            showSplash = false
                        }
                    }
                }
            }
            .onChange(of: appState.isAuthReady) { _, isReady in
                if isReady && splashMinTimePassed {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
            .onChange(of: appState.authFailed) { _, failed in
                if failed && splashMinTimePassed {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var hasSeenOnboarding: Bool
    @Published var hasCompletedSetup: Bool
    @Published var isAuthReady = false
    @Published var authFailed = false

    private var authSetupDone = false
    private var retryCount = 0
    private let maxRetries = 3

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        self.hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
    }

    func completeOnboarding() {
        print("completeOnboarding called")
        hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        print("hasSeenOnboarding is now: \(hasSeenOnboarding)")
    }

    func completeSetup() {
        print("completeSetup called")
        hasCompletedSetup = true
        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
        print("hasCompletedSetup is now: \(hasCompletedSetup)")
    }

    func setupAuth() {
        guard !authSetupDone else { return }
        authSetupDone = true
        attemptAuth()
    }

    func retryAuth() {
        retryCount = 0
        authFailed = false
        attemptAuth()
    }

    private func attemptAuth() {
        // Check current user first
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.isAuthReady = true
            }
            return
        }

        // Sign in anonymously
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Anonymous auth error (attempt \(self.retryCount + 1)): \(error.localizedDescription)")
                self.retryCount += 1

                if self.retryCount < self.maxRetries {
                    // Exponential backoff: 1s, 2s, 4s
                    let delay = pow(2.0, Double(self.retryCount - 1))
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.attemptAuth()
                    }
                } else {
                    // All retries failed
                    DispatchQueue.main.async {
                        self.authFailed = true
                    }
                }
                return
            }

            // Success
            DispatchQueue.main.async {
                self.isAuthReady = true
            }
        }
    }
}
