import SwiftUI

struct LocationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var locationFilter: String
    let allProjects: [Project]

    @State private var searchText = ""

    var allLocations: [String] {
        let raw = allProjects.flatMap { $0.neededItems.map(\.location) }
        let unique = Array(Set(raw.filter { !$0.isEmpty })).sorted()
        if searchText.isEmpty { return unique }
        return unique.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !locationFilter.isEmpty {
                    Section {
                        Button(role: .destructive) {
                            locationFilter = ""
                            dismiss()
                        } label: {
                            Label("Clear filter (\"\(locationFilter)\")", systemImage: "xmark.circle")
                        }
                    }
                }

                Section("Locations across all projects") {
                    if allLocations.isEmpty {
                        Text("No locations recorded yet.")
                            .foregroundColor(.secondary)
                    }
                    ForEach(allLocations, id: \.self) { loc in
                        Button {
                            locationFilter = loc
                            dismiss()
                        } label: {
                            HStack {
                                Text(loc)
                                Spacer()
                                if locationFilter == loc {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search locations")
            .navigationTitle("Filter by Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
