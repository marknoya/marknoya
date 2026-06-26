# Project Manager — Native iOS App

A personal project management app for iPhone. Captures thoughts from a structured text file, organizes them into projects with tasks and prep workflows, and tracks progress with a priority/deadline dashboard.

## Requirements

- **Xcode 15+**
- **iOS 17.0+** (SwiftData requires iOS 17)
- **Swift 5.9+**

## Opening the Project

```
open ProjectManager/ProjectManager.xcodeproj
```

Select your device or simulator, then build and run.

## Thoughts File Format

Create a plain text file (e.g. `thoughts.txt`) using voice-to-text or typing:

```
# Fix kitchen faucet
Buy replacement cartridge from hardware store
Turn off water supply under sink
Remove handle and swap cartridge

# Plan camping trip
Book campsite at state park
Pack gear list: tent sleeping bag stove
Buy food for three days
```

- Lines starting with `#` become project names
- Lines below each header become tasks
- Blank lines separate projects (optional)

Import via the **Import** button on the dashboard — choose a file or paste text directly.

## Architecture

```
ProjectManager/
  Models/
    Project.swift              SwiftData model — core project entity
    ProjectTask.swift          Individual task within a project
    NeededItem.swift           Item needed to complete the project
    LaborRequirement.swift     Person/contractor needed for the project
    ContractorSubTask.swift    Find/contact/quote/hire/schedule steps
    ParsedProject.swift        Transient struct used during import
  Services/
    PersistenceController.swift  ModelContainer setup
    ThoughtsFileParser.swift     Parses # Topic / task text format
    NotificationManager.swift    UNUserNotificationCenter wrapper
  Views/
    Dashboard/    Project list with progress, priority, status badges
    Import/       File picker + paste import + review/commit flow
    ProjectDetail/  Task list, progress, prep summary, reminders toggle
    ProjectPrep/  Needed items, labor requirements, contractor workflow
    Setup/        Edit name, priority, start date, due date
    Reminders/    Per-project notification frequency and intensity
    Components/   ProgressBarView, StatusBadgeView, LocationFilterView
```

## Key Features

| Feature | Details |
|---|---|
| Import | Parse `# Topic` text files; review before committing |
| Progress | Auto-calculated from task completion checkboxes |
| Status badges | Blocked (red), Prep (blue), Ready (green), In Progress (orange) |
| Blockers | Flag needed items/labor as blocking; count shown on dashboard |
| Contractor workflow | 5-step sub-checklist: find → contact → quote → hire → schedule |
| Location filter | Group needed items by store/location across all projects |
| Reminders | Per-project: daily/weekly/bi-weekly/monthly, gentle to persistent |
| Offline | All data stored locally via SwiftData, no network required |

## Future: AI Integration Hook

The architecture is designed to accept an AI suggestion engine. To add it:

1. Create a `SuggestionEngine` protocol in `Services/`
2. Implement adapters for Claude, Siri Shortcuts, or other providers
3. Add a toggle in Settings to enable/disable suggestions
4. Hook into `ProjectSetupView` and `ProjectPrepView` to surface prompts

The app has no AI dependency in v1 — it ships fully functional without it.

## Local Storage

All data persists via **SwiftData** in the app's default container (sandboxed to the device). No iCloud sync, no network calls.
