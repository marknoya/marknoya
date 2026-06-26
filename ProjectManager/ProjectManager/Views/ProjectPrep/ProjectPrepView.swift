import SwiftUI
import SwiftData

struct ProjectPrepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project

    @State private var showAddNeededItem = false
    @State private var showAddLabor = false
    @State private var neededItemSort: NeededItemSort = .blocker
    @State private var neededExpanded = true
    @State private var laborExpanded = true

    enum NeededItemSort: String, CaseIterable {
        case blocker = "Blocker Status"
        case location = "Location"
        case status = "Completion"
    }

    var sortedNeededItems: [NeededItem] {
        switch neededItemSort {
        case .blocker:
            return project.neededItems.sorted { $0.isBlocker && !$1.isBlocker }
        case .location:
            return project.neededItems.sorted { $0.location < $1.location }
        case .status:
            return project.neededItems.sorted { !$0.isCompleted && $1.isCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                blockersSummarySection
                neededItemsSection
                laborSection
            }
            .navigationTitle("Project Prep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddNeededItem) {
                AddNeededItemSheet(project: project)
            }
            .sheet(isPresented: $showAddLabor) {
                AddLaborSheet(project: project)
            }
        }
    }

    var blockersSummarySection: some View {
        Section {
            let blockers = project.blockingItemsCount
            if blockers > 0 {
                Label("\(blockers) blocking item(s) must be resolved before starting", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            } else {
                Label("No blockers \u{2014} ready to go!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        } header: {
            Text("Blocker Status")
        }
    }

    var neededItemsSection: some View {
        Section {
            DisclosureGroup(isExpanded: $neededExpanded) {
                Picker("Sort by", selection: $neededItemSort) {
                    ForEach(NeededItemSort.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)

                ForEach(sortedNeededItems) { item in
                    NeededItemRowView(item: item)
                }
                .onDelete { offsets in
                    deleteNeededItems(at: offsets)
                }

                Button { showAddNeededItem = true } label: {
                    Label("Add Needed Item", systemImage: "plus")
                }
            } label: {
                HStack {
                    Text("Needed Items (\(project.neededItems.count))")
                        .font(.headline)
                    Spacer()
                    let blocking = project.neededItems.filter { $0.isBlocker && !$0.isCompleted }.count
                    if blocking > 0 {
                        Text("\(blocking) blocking")
                            .font(.caption).foregroundColor(.red)
                    }
                }
            }
        }
    }

    var laborSection: some View {
        Section {
            DisclosureGroup(isExpanded: $laborExpanded) {
                ForEach(project.laborRequirements) { labor in
                    LaborRowView(labor: labor)
                }
                .onDelete { offsets in
                    deleteLabor(at: offsets)
                }
                Button { showAddLabor = true } label: {
                    Label("Add Labor Requirement", systemImage: "plus")
                }
            } label: {
                HStack {
                    Text("Labor Requirements (\(project.laborRequirements.count))")
                        .font(.headline)
                    Spacer()
                    let blocking = project.laborRequirements.filter { $0.isBlocker && !$0.isCompleted }.count
                    if blocking > 0 {
                        Text("\(blocking) blocking")
                            .font(.caption).foregroundColor(.red)
                    }
                }
            }
        }
    }

    func deleteNeededItems(at offsets: IndexSet) {
        let sorted = sortedNeededItems
        for i in offsets { modelContext.delete(sorted[i]) }
        try? modelContext.save()
    }

    func deleteLabor(at offsets: IndexSet) {
        let all = project.laborRequirements
        for i in offsets { modelContext.delete(all[i]) }
        try? modelContext.save()
    }
}

struct NeededItemRowView: View {
    @Bindable var item: NeededItem
    @State private var showEdit = false

    var body: some View {
        HStack(spacing: 12) {
            Button { item.isCompleted.toggle() } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.itemDescription)
                    .font(.subheadline)
                    .strikethrough(item.isCompleted, color: .secondary)
                if !item.location.isEmpty {
                    Text(item.location)
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            if item.isBlocker {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red).font(.caption)
            }
        }
        .swipeActions(edge: .trailing) {
            Button { showEdit = true } label: {
                Label("Edit", systemImage: "pencil")
            }.tint(.blue)
        }
        .sheet(isPresented: $showEdit) {
            EditNeededItemSheet(item: item)
        }
    }
}

struct LaborRowView: View {
    @Bindable var labor: LaborRequirement
    @State private var contractorExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Button { labor.isCompleted.toggle() } label: {
                    Image(systemName: labor.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(labor.isCompleted ? .green : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(labor.laborDescription)
                        .font(.subheadline)
                        .strikethrough(labor.isCompleted, color: .secondary)
                    Text(labor.laborType.rawValue)
                        .font(.caption).foregroundColor(.accentColor)
                }
                Spacer()
                if labor.isBlocker {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red).font(.caption)
                }
            }
            .padding(.vertical, 4)

            if labor.isExternalContractor {
                ContractorWorkflowView(labor: labor)
                    .padding(.leading, 36)
            }
        }
    }
}

struct AddNeededItemSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let project: Project
    @State private var description = ""
    @State private var location = ""
    @State private var isBlocker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Description", text: $description)
                    TextField("Location / Store", text: $location)
                }
                Section {
                    Toggle("Blocking (cannot start without this)", isOn: $isBlocker)
                }
            }
            .navigationTitle("Add Needed Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = NeededItem(description: description, location: location, isBlocker: isBlocker)
                        item.project = project
                        modelContext.insert(item)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EditNeededItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: NeededItem

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Description", text: $item.itemDescription)
                    TextField("Location / Store", text: $item.location)
                }
                Section {
                    Toggle("Blocking (cannot start without this)", isOn: $item.isBlocker)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

struct AddLaborSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let project: Project
    @State private var description = ""
    @State private var laborType: LaborType = .phoneAFriend
    @State private var isBlocker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Labor") {
                    TextField("Description", text: $description)
                    Picker("Type", selection: $laborType) {
                        ForEach(LaborType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }
                Section {
                    Toggle("Blocking", isOn: $isBlocker)
                }
            }
            .navigationTitle("Add Labor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let labor = LaborRequirement(description: description, type: laborType, isBlocker: isBlocker)
                        labor.project = project
                        modelContext.insert(labor)
                        if laborType == .externalContractor {
                            for step in ContractorStep.allCases {
                                let sub = ContractorSubTask(step: step)
                                sub.laborRequirement = labor
                                modelContext.insert(sub)
                            }
                        }
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
