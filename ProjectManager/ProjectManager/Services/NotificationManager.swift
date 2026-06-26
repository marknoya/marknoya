import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleReminder(for project: Project) {
        guard project.remindersEnabled else { return }
        cancelReminder(for: project)

        let content = UNMutableNotificationContent()
        content.title = "Project Reminder"
        content.body = "\(project.name) — \(Int(project.progressPercentage))% complete"
        content.sound = .default
        if project.reminderIntensity >= 4 {
            content.interruptionLevel = .timeSensitive
        }

        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        switch project.reminderFrequency {
        case .daily:
            break
        case .weekly, .biweekly:
            components.weekday = 2
        case .monthly:
            components.day = 1
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: project.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for project: Project) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [project.id.uuidString]
        )
    }

    func updateReminder(for project: Project) {
        cancelReminder(for: project)
        scheduleReminder(for: project)
    }
}
