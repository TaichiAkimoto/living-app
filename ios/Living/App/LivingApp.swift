import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LivingApp: App {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var isAuthReady = false

    init() {
        FirebaseApp.configure()

        // Anonymous Auth でサインイン
        signInAnonymously()
    }

    var body: some Scene {
        WindowGroup {
            if isAuthReady {
                if hasCompletedSetup {
                    CheckInView()
                } else {
                    SettingsView(isInitialSetup: true)
                }
            } else {
                // 認証準備中の表示
                ProgressView("Loading...")
                    .onAppear {
                        checkAuthState()
                    }
            }
        }
    }

    private func signInAnonymously() {
        // 既にサインイン済みの場合はスキップ
        if Auth.auth().currentUser != nil {
            return
        }

        Auth.auth().signInAnonymously { _, error in
            if let error = error {
                print("Anonymous auth error: \(error.localizedDescription)")
            }
        }
    }

    private func checkAuthState() {
        // 認証状態の監視
        Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                isAuthReady = true
            } else {
                // 未サインインの場合は再度サインイン
                signInAnonymously()
            }
        }
    }
}
