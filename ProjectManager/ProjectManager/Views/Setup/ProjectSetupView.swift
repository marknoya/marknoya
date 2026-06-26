import SwiftUI

struct ProjectSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project

    @State private var hasStartDate: Bool
    @State private var hasDueDate: Bool

    init(project: Project) {
        self.project = project
        _hasStartDate = State(initialValue: project.startDate != nil)
        _hasDueDate = State(initialValue: project.completedByDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Name") {
                    TextField("Name", text: $project.name)
                }

                Section("Priority") {
                    Picker("Priority", selection: $project.priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Start Date") {
                    Toggle("Set start date", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker(
                            "Start Date",
                            selection: Binding(
                                get: { project.startDate ?? Date() },
                                set: { project.startDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                .onChange(of: hasStartDate) { _, on in
                    if !on { project.startDate = nil }
                    else if project.startDate == nil { project.startDate = Date() }
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            "Complete By",
                            selection: Binding(
                                get: { project.completedByDate ?? Date() },
                                set: { project.completedByDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                .onChange(of: hasDueDate) { _, on in
                    if !on { project.completedByDate = nil }
                    else if project.completedByDate == nil { project.completedByDate = Date() }
                }

                Section {
                    Toggle("In prep phase", isOn: $project.isInPrepPhase)
                } footer: {
                    Text("Mark as in prep phase while gathering needed items and lining up labor.")
                }
            }
            .navigationTitle("Project Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
