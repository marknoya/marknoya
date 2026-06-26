import SwiftUI

struct StatusBadgeView: View {
    let status: ProjectStatus

    var body: some View {
        Text(status.label)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(4)
    }

    var badgeColor: Color {
        switch status {
        case .blocked: return .red
        case .prep: return .blue
        case .readyToStart: return .green
        case .inProgress: return .orange
        case .complete: return .gray
        }
    }
}
