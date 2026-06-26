import Foundation

struct ThoughtsFileParser {
    /// Parses text with format: # Topic\ntask line\ntask line\n\n# Next Topic\n...
    static func parse(text: String) -> [ParsedProject] {
        var projects: [ParsedProject] = []
        var currentName: String? = nil
        var currentTasks: [ParsedTask] = []

        for line in text.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") {
                if let name = currentName, !name.isEmpty {
                    projects.append(ParsedProject(name: name, tasks: currentTasks))
                }
                currentName = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                currentTasks = []
            } else if !trimmed.isEmpty, currentName != nil {
                currentTasks.append(ParsedTask(description: trimmed))
            }
        }

        if let name = currentName, !name.isEmpty {
            projects.append(ParsedProject(name: name, tasks: currentTasks))
        }

        return projects
    }
}
