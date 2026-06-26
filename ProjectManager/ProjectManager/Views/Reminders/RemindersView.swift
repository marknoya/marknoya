import SwiftUI

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: Project

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Reminders", isOn: $project.remindersEnabled)
                        .onChange(of: project.remindersEnabled) { _, enabled in
                            if enabled {
                                NotificationManager.shared.requestPermission()
                                NotificationManager.shared.scheduleReminder(for: project)
                            } else {
                                NotificationManager.shared.cancelReminder(for: project)
                            }
                        }
                } footer: {
                    Text("Reminders will notify you to check in on this project.")
                }

                if project.remindersEnabled {
                    Section("Frequency") {
                        Picker("Frequency", selection: $project.reminderFrequency) {
                            ForEach(ReminderFrequency.allCases, id: \.self) { f in
                                Text(f.rawValue).tag(f)
                            }
                        }
                        .pickerStyle(.inline)
                        .onChange(of: project.reminderFrequencyRaw) { _, _ in
                            NotificationManager.shared.updateReminder(for: project)
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Intensity")
                                Spacer()
                                Text(intensityLabel(project.reminderIntensity))
                                    .foregroundColor(.secondary)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(project.reminderIntensity) },
                                    set: { project.reminderIntensity = Int($0) }
                                ),
                                in: 1...5,
                                step: 1
                            )
                            .onChange(of: project.reminderIntensity) { _, _ in
                                NotificationManager.shared.updateReminder(for: project)
                            }
                        }
                    } header: {
                        Text("Intensity")
                    } footer: {
                        Text("Higher intensity enables time-sensitive notifications (iOS 15+).")
                    }
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    func intensityLabel(_ value: Int) -> String {
        switch value {
        case 1: return "Gentle"
        case 2: return "Mild"
        case 3: return "Normal"
        case 4: return "Firm"
        case 5: return "Persistent"
        default: return "Normal"
        }
    }
}
