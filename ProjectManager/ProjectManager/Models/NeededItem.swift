import Foundation
import SwiftData

@Model
final class NeededItem {
    var id: UUID
    var itemDescription: String
    var location: String
    var isBlocker: Bool
    var isCompleted: Bool
    var project: Project?

    init(description: String, location: String = "", isBlocker: Bool = false) {
        self.id = UUID()
        self.itemDescription = description
        self.location = location
        self.isBlocker = isBlocker
        self.isCompleted = false
    }
}
