import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project

    @State private var showSetup = false
    @State private var showPrep = false
    @State private var showReminders = false
    @State private var showAddTask = false
    @State private var newTaskText = ""
    @State private var showDeleteConfirm = false
    @State private var prepExpanded = true
    @State private var tasksExpanded = true

    var body: some View {
        List {
            headerSection
            progressSection
            if tasksExpanded { taskSection }
            prepSection
            remindersSection
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showSetup = true } label: {
                        Label("Edit Setup", systemImage: "pencil")
                    }
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete Project", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showSetup) { ProjectSetupView(project: project) }
        .sheet(isPresented: $showPrep) { ProjectPrepView(project: project) }
        .sheet(isPresented: $showReminders) { RemindersView(project: project) }
        .confirmationDialog("Delete \"\(project.name)\"?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Project", role: .destructive) {
                modelContext.delete(project)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    var headerSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let start = project.startDate {
                        Label(start.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    if let due = project.completedByDate {
                        Label(due.formatted(date: .abbreviated, time: .omitted), systemImage: "flag")
                            .font(.subheadline)
                            .foregroundColor(due < Date() ? .red : .secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    PriorityBadge(priority: project.priority)
                    StatusBadgeView(status: project.status)
                }
            }
            Button { showSetup = true } label: {
                Label("Edit Dates & Priority", systemImage: "pencil")
                    .font(.subheadline)
            }
        }
    }

    var progressSection: some View {
        Section("Progress") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(Int(project.progressPercentage))% complete")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text("\(project.tasks.filter(\.isCompleted).count)/\(project.tasks.count) tasks")
                        .font(.caption).foregroundColor(.secondary)
                }
                ProgressBarView(percentage: project.progressPercentage)
            }
            .padding(.vertical, 2)
        }
    }

    var taskSection: some View {
        Section {
            DisclosureGroup(isExpanded: $tasksExpanded) {
                ForEach(project.tasks.sorted { $0.order < $1.order }) { task in
                    TaskRowView(task: task)
                }
                .onDelete { offsets in
                    deleteTasks(at: offsets)
                }
                Button { showAddTask = true } label: {
                    Label("Add Task", systemImage: "plus")
                        .font(.subheadline)
                }
            } label: {
                Text("Tasks (\(project.tasks.count))")
                    .font(.headline)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet(project: project)
        }
    }

    var prepSection: some View {
        Section {
            DisclosureGroup(isExpanded: $prepExpanded) {
                if project.blockingItemsCount > 0 {
                    Label("\(project.blockingItemsCount) blocker(s) remaining", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                Button { showPrep = true } label: {
                    Label("Manage Prep Phase", systemImage: "checklist")
                        .font(.subheadline)
                }
                if !project.neededItems.isEmpty {
                    Text("\(project.neededItems.filter { !$0.isCompleted }.count) needed items pending")
                        .font(.caption).foregroundColor(.secondary)
                }
                if !project.laborRequirements.isEmpty {
                    Text("\(project.laborRequirements.filter { !$0.isCompleted }.count) labor requirements pending")
                        .font(.caption).foregroundColor(.secondary)
                }
            } label: {
                HStack {
                    Text("Project Prep")
                        .font(.headline)
                    Spacer()
                    if project.blockingItemsCount > 0 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
        }
    }

    var remindersSection: some View {
        Section("Reminders") {
            HStack {
                Toggle(isOn: $project.remindersEnabled) {
                    Label("Enable Reminders", systemImage: "bell")
                }
                .onChange(of: project.remindersEnabled) { _, enabled in
                    if enabled {
                        NotificationManager.shared.scheduleReminder(for: project)
                    } else {
                        NotificationManager.shared.cancelReminder(for: project)
                    }
                }
            }
            if project.remindersEnabled {
                Button { showReminders = true } label: {
                    Label("Configure Reminders", systemImage: "bell.badge")
                        .font(.subheadline)
                }
            }
        }
    }

    func deleteTasks(at offsets: IndexSet) {
        let sorted = project.tasks.sorted { $0.order < $1.order }
        for i in offsets { modelContext.delete(sorted[i]) }
        try? modelContext.save()
    }
}

struct TaskRowView: View {
    @Bindable var task: ProjectTask

    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            Text(task.taskDescription)
                .font(.subheadline)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
        }
    }
}

struct AddTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let project: Project
    @State private var text = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task description", text: $text, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let t = ProjectTask(description: text, order: project.tasks.count)
                        t.project = project
                        modelContext.insert(t)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
