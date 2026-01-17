import Foundation

@MainActor
final class CheckInViewModel: ObservableObject {
    @Published var lastCheckIn: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared

    func loadLastCheckIn() {
        Task {
            lastCheckIn = await firebaseService.getLastCheckIn()
        }
    }

    func checkIn() async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.updateCheckIn()
            lastCheckIn = Date()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "チェックインに失敗しました"
            print("Check-in error: \(error)")
        }
    }
}
