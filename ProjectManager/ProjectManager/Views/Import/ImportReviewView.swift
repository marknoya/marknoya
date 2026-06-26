import SwiftUI
import SwiftData

struct ImportReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let batch: ImportBatch
    let onCommit: () -> Void

    @State private var selectedProjects: Set<UUID> = []
    @State private var editedProjects: [ParsedProject]

    init(batch: ImportBatch, onCommit: @escaping () -> Void) {
        self.batch = batch
        self.onCommit = onCommit
        _editedProjects = State(initialValue: batch.projects)
        _selectedProjects = State(initialValue: Set(batch.projects.map(\.id)))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Imported \(batch.importDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Select projects to commit. Deselected projects will be discarded.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                ForEach($editedProjects) { $project in
                    Section {
                        HStack {
                            Image(systemName: selectedProjects.contains(project.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedProjects.contains(project.id) ? .accentColor : .secondary)
                                .onTapGesture { toggleSelection(project.id) }
                            TextField("Project name", text: $project.name)
                                .font(.headline)
                        }
                        ForEach(project.tasks.indices, id: \.self) { idx in
                            HStack {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                                    .onTapGesture { removeTask(from: project.id, at: idx) }
                                Text(project.tasks[idx].description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Button {
                            addTask(to: project.id)
                        } label: {
                            Label("Add Task", systemImage: "plus")
                                .font(.caption)
                        }
                    } header: {
                        Text("\(project.tasks.count) task(s)")
                    }
                }
            }
            .navigationTitle("Review Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Discard") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Commit") {
                        commitSelected()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedProjects.isEmpty)
                }
            }
        }
    }

    func toggleSelection(_ id: UUID) {
        if selectedProjects.contains(id) {
            selectedProjects.remove(id)
        } else {
            selectedProjects.insert(id)
        }
    }

    func removeTask(from projectID: UUID, at index: Int) {
        guard let pi = editedProjects.firstIndex(where: { $0.id == projectID }) else { return }
        editedProjects[pi].tasks.remove(at: index)
    }

    func addTask(to projectID: UUID) {
        guard let pi = editedProjects.firstIndex(where: { $0.id == projectID }) else { return }
        editedProjects[pi].tasks.append(ParsedTask(description: "New task"))
    }

    func commitSelected() {
        let toCommit = editedProjects.filter { selectedProjects.contains($0.id) }
        for parsed in toCommit {
            let project = Project(name: parsed.name)
            modelContext.insert(project)
            for (i, task) in parsed.tasks.enumerated() {
                let t = ProjectTask(description: task.description, order: i)
                t.project = project
                modelContext.insert(t)
            }
        }
        try? modelContext.save()
        onCommit()
    }
}
