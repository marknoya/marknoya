import Foundation
import SwiftData

enum ContractorStep: String, Codable, CaseIterable {
    case find = "Find Contractor"
    case contact = "Contact Them"
    case quote = "Get Quote"
    case hire = "Hire Them"
    case schedule = "Schedule Them"
}

@Model
final class ContractorSubTask {
    var id: UUID
    var stepRaw: String
    var isCompleted: Bool
    var laborRequirement: LaborRequirement?

    init(step: ContractorStep) {
        self.id = UUID()
        self.stepRaw = step.rawValue
        self.isCompleted = false
    }

    var step: ContractorStep {
        ContractorStep(rawValue: stepRaw) ?? .find
    }
}
