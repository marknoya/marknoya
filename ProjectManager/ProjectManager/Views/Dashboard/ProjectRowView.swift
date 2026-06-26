import SwiftUI

struct ProjectRowView: View {
    let project: Project
    var locationFilter: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                PriorityBadge(priority: project.priority)
                StatusBadgeView(status: project.status)
            }

            ProgressBarView(percentage: project.progressPercentage)

            HStack(spacing: 12) {
                if let start = project.startDate {
                    Label(start.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let due = project.completedByDate {
                    Label(due.formatted(date: .abbreviated, time: .omitted), systemImage: "flag")
                        .font(.caption)
                        .foregroundColor(due < Date() ? .red : .secondary)
                }
                Spacer()
                if project.blockingItemsCount > 0 {
                    Label("\(project.blockingItemsCount) blockers", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            if !locationFilter.isEmpty {
                let matchingItems = project.neededItems.filter {
                    $0.location.localizedCaseInsensitiveContains(locationFilter)
                }
                if !matchingItems.isEmpty {
                    Text("\(matchingItems.count) item(s) at \(locationFilter)")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }

    var priorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
