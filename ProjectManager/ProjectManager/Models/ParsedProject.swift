import Foundation

struct ParsedTask {
    var description: String
}

struct ParsedProject: Identifiable {
    var id = UUID()
    var name: String
    var tasks: [ParsedTask]
}

struct ImportBatch: Identifiable {
    var id = UUID()
    var projects: [ParsedProject]
    var importDate: Date
    var sourceText: String
}
