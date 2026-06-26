import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt) private var projects: [Project]

    @State private var showImport = false
    @State private var sortOption: SortOption = .priorityAndDate
    @State private var locationFilter = ""
    @State private var showLocationFilter = false

    enum SortOption: String, CaseIterable {
        case priorityAndDate = "Priority & Date"
        case progress = "Progress"
        case status = "Status"
    }

    var sortedProjects: [Project] {
        let filtered = locationFilter.isEmpty ? projects : projects.filter { project in
            project.neededItems.contains { $0.location.localizedCaseInsensitiveContains(locationFilter) }
        }
        switch sortOption {
        case .priorityAndDate:
            return filtered.sorted {
                if $0.priority.sortOrder != $1.priority.sortOrder {
                    return $0.priority.sortOrder > $1.priority.sortOrder
                }
                switch ($0.startDate, $1.startDate) {
                case (.some(let a), .some(let b)): return a < b
                case (.some, .none): return true
                default: return $0.name < $1.name
                }
            }
        case .progress:
            return filtered.sorted { $0.progressPercentage < $1.progressPercentage }
        case .status:
            return filtered.sorted { statusOrder($0.status) < statusOrder($1.status) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showImport = true } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                        Divider()
                        Button { showLocationFilter = true } label: {
                            Label("Filter by Location", systemImage: "mappin.and.ellipse")
                        }
                        if !locationFilter.isEmpty {
                            Button(role: .destructive) { locationFilter = "" } label: {
                                Label("Clear Location Filter", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Label("Options", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showImport) {
                ImportView()
            }
            .sheet(isPresented: $showLocationFilter) {
                LocationFilterView(locationFilter: $locationFilter, allProjects: projects)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Projects Yet")
                .font(.title2).fontWeight(.semibold)
            Text("Import a thoughts file to get started")
                .foregroundColor(.secondary)
            Button { showImport = true } label: {
                Label("Import Thoughts", systemImage: "square.and.arrow.down")
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    var projectList: some View {
        List {
            if !locationFilter.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "mappin.and.ellipse").foregroundColor(.secondary)
                        Text("Showing items near: \(locationFilter)").font(.caption)
                        Spacer()
                        Button("Clear") { locationFilter = "" }.font(.caption)
                    }
                }
            }
            ForEach(sortedProjects) { project in
                NavigationLink(destination: ProjectDetailView(project: project)) {
                    ProjectRowView(project: project, locationFilter: locationFilter)
                }
            }
            .onDelete(perform: deleteProjects)
        }
    }

    func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedProjects[index])
        }
    }

    func statusOrder(_ s: ProjectStatus) -> Int {
        switch s {
        case .blocked: return 0
        case .inProgress: return 1
        case .prep: return 2
        case .readyToStart: return 3
        case .complete: return 4
        }
    }
}
