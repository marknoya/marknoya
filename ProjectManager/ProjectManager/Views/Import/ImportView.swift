import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showFilePicker = false
    @State private var importBatch: ImportBatch? = nil
    @State private var pastedText = ""
    @State private var importMode: ImportMode = .file
    @State private var showReview = false
    @State private var errorMessage: String? = nil

    enum ImportMode: String, CaseIterable {
        case file = "File"
        case paste = "Paste Text"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Import Mode", selection: $importMode) {
                        ForEach(ImportMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if importMode == .file {
                    Section {
                        Button {
                            showFilePicker = true
                        } label: {
                            Label("Choose thoughts.txt", systemImage: "doc.text")
                        }
                    } footer: {
                        Text("Select a plain text file formatted with # Topic headers and task lines.")
                    }
                } else {
                    Section("Paste your thoughts") {
                        TextEditor(text: $pastedText)
                            .frame(minHeight: 200)
                            .font(.system(.body, design: .monospaced))
                    }
                    Section {
                        Button("Parse Text") {
                            parseText(pastedText)
                        }
                        .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Import Thoughts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .sheet(item: $importBatch) { batch in
                ImportReviewView(batch: batch) {
                    dismiss()
                }
            }
        }
    }

    func parseText(_ text: String) {
        errorMessage = nil
        let parsed = ThoughtsFileParser.parse(text: text)
        if parsed.isEmpty {
            errorMessage = "No projects found. Make sure your text uses # Topic headers."
            return
        }
        importBatch = ImportBatch(projects: parsed, importDate: Date(), sourceText: text)
        showReview = true
    }

    func handleFileImport(_ result: Result<[URL], Error>) {
        errorMessage = nil
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    errorMessage = "Permission denied for file."
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                let text = try String(contentsOf: url, encoding: .utf8)
                parseText(text)
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
        case .failure(let error):
            errorMessage = "File import failed: \(error.localizedDescription)"
        }
    }
}
