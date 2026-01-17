import SwiftUI
import FirebaseCore

@main
struct LivingApp: App {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedSetup {
                CheckInView()
            } else {
                SettingsView(isInitialSetup: true)
            }
        }
    }
}
