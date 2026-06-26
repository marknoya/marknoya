import SwiftUI

struct ContractorWorkflowView: View {
    @Bindable var labor: LaborRequirement
    @State private var expanded = false

    var sortedSteps: [ContractorSubTask] {
        let order = ContractorStep.allCases.map(\.rawValue)
        return labor.contractorSubTasks.sorted {
            (order.firstIndex(of: $0.stepRaw) ?? 0) < (order.firstIndex(of: $1.stepRaw) ?? 0)
        }
    }

    var completedCount: Int { labor.contractorSubTasks.filter(\.isCompleted).count }

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            ForEach(sortedSteps) { subTask in
                HStack {
                    Button { subTask.isCompleted.toggle() } label: {
                        Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(subTask.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    Text(subTask.step.rawValue)
                        .font(.caption)
                        .strikethrough(subTask.isCompleted, color: .secondary)
                        .foregroundColor(subTask.isCompleted ? .secondary : .primary)
                }
            }
        } label: {
            HStack {
                Image(systemName: "person.badge.shield.checkmark")
                    .foregroundColor(.accentColor)
                    .font(.caption)
                Text("Contractor Steps (\(completedCount)/\(labor.contractorSubTasks.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
