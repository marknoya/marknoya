import Foundation
import SwiftData

enum LaborType: String, Codable, CaseIterable {
    case phoneAFriend = "Phone a Friend"
    case externalContractor = "External Contractor"
}

@Model
final class LaborRequirement {
    var id: UUID
    var laborDescription: String
    var laborTypeRaw: String
    var isBlocker: Bool
    var isCompleted: Bool
    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \ContractorSubTask.laborRequirement)
    var contractorSubTasks: [ContractorSubTask] = []

    init(description: String, type: LaborType = .phoneAFriend, isBlocker: Bool = false) {
        self.id = UUID()
        self.laborDescription = description
        self.laborTypeRaw = type.rawValue
        self.isBlocker = isBlocker
        self.isCompleted = false
    }

    var laborType: LaborType {
        get { LaborType(rawValue: laborTypeRaw) ?? .phoneAFriend }
        set { laborTypeRaw = newValue.rawValue }
    }

    var isExternalContractor: Bool { laborType == .externalContractor }
}
