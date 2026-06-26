import SwiftData
import Foundation

@MainActor
class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        let schema = Schema([
            Project.self,
            ProjectTask.self,
            NeededItem.self,
            LaborRequirement.self,
            ContractorSubTask.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
