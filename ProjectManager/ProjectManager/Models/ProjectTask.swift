import Foundation
import SwiftData

@Model
final class ProjectTask {
    var id: UUID
    var taskDescription: String
    var isCompleted: Bool
    var order: Int
    var project: Project?

    init(description: String, order: Int = 0) {
        self.id = UUID()
        self.taskDescription = description
        self.isCompleted = false
        self.order = order
    }
}
