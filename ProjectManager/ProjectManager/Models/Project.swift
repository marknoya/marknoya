import Foundation
import SwiftData

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
}

enum ProjectStatus {
    case prep, blocked, readyToStart, inProgress, complete

    var label: String {
        switch self {
        case .prep: return "Prep"
        case .blocked: return "Blocked"
        case .readyToStart: return "Ready"
        case .inProgress: return "In Progress"
        case .complete: return "Complete"
        }
    }
}

@Model
final class Project {
    var id: UUID
    var name: String
    var startDate: Date?
    var completedByDate: Date?
    var priorityRaw: String
    var remindersEnabled: Bool
    var reminderFrequencyRaw: String
    var reminderIntensity: Int
    var createdAt: Date
    var isInPrepPhase: Bool

    @Relationship(deleteRule: .cascade, inverse: \ProjectTask.project)
    var tasks: [ProjectTask] = []

    @Relationship(deleteRule: .cascade, inverse: \NeededItem.project)
    var neededItems: [NeededItem] = []

    @Relationship(deleteRule: .cascade, inverse: \LaborRequirement.project)
    var laborRequirements: [LaborRequirement] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.priorityRaw = Priority.medium.rawValue
        self.remindersEnabled = false
        self.reminderFrequencyRaw = ReminderFrequency.weekly.rawValue
        self.reminderIntensity = 2
        self.createdAt = Date()
        self.isInPrepPhase = true
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var reminderFrequency: ReminderFrequency {
        get { ReminderFrequency(rawValue: reminderFrequencyRaw) ?? .weekly }
        set { reminderFrequencyRaw = newValue.rawValue }
    }

    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter(\.isCompleted).count
        return Double(completed) / Double(tasks.count) * 100
    }

    var isComplete: Bool {
        !tasks.isEmpty && tasks.allSatisfy(\.isCompleted)
    }

    var blockingItemsCount: Int {
        let blockedNeeds = neededItems.filter { $0.isBlocker && !$0.isCompleted }.count
        let blockedLabor = laborRequirements.filter { $0.isBlocker && !$0.isCompleted }.count
        return blockedNeeds + blockedLabor
    }

    var isBlocked: Bool { blockingItemsCount > 0 }

    var status: ProjectStatus {
        if isComplete { return .complete }
        if isBlocked {
            if let start = startDate, Calendar.current.isDateInToday(start) {
                return .blocked
            }
        }
        if progressPercentage > 0 { return .inProgress }
        if isInPrepPhase && (!neededItems.isEmpty || !laborRequirements.isEmpty) { return .prep }
        return .readyToStart
    }
}
