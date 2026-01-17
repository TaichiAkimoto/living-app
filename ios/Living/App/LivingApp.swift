import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LivingApp: App {
    @StateObject private var appState = AppState()
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                if showSplash {
                    SplashView()
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
                    ProgressView("Loading...")
                }
            }
            .onAppear {
                // Start auth flow immediately
                appState.setupAuth()

                // Show splash for 2.5 seconds then transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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

    private var authSetupDone = false

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

        // Check current user first
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.isAuthReady = true
            }
            return
        }

        // Sign in anonymously
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                print("Anonymous auth error: \(error.localizedDescription)")
            }
            // Always proceed
            DispatchQueue.main.async {
                self?.isAuthReady = true
            }
        }
    }
}
