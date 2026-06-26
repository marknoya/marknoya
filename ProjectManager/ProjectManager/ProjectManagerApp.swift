import SwiftUI
import SwiftData

@main
struct ProjectManagerApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
