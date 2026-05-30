import Foundation
import UserNotifications

extension NotificationManager {
    func scheduleProjectNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        secondsFromNow: TimeInterval = 2
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(secondsFromNow, 1), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Bildirim planlanamadı: \(error.localizedDescription)")
            }
        }
    }

    func scheduleJobUpdateNotification(count: Int, firstTitle: String?) {
        let title = "Yeni staj/iş ilanları bulundu"
        let first = firstTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let body: String
        if count == 1, !first.isEmpty {
            body = "Yeni ilan: \(first)"
        } else if !first.isEmpty {
            body = "\(count) yeni ilan var. İlk ilan: \(first)"
        } else {
            body = "\(count) yeni ilan bulundu. Staj İlanları ekranından kontrol edebilirsin."
        }

        scheduleProjectNotification(
            id: "new-jobs-\(Date().timeIntervalSince1970)",
            title: title,
            body: body,
            secondsFromNow: 2
        )
    }

    func scheduleApplicationDeadlineNotification(for internship: Internship) {
        guard let deadline = internship.applicationDeadline else { return }

        let calendar = Calendar.current
        let reminderDate = calendar.date(byAdding: .day, value: -1, to: deadline) ?? deadline
        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = 9
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Başvuru deadline yaklaşıyor"
        content.body = "\(internship.companyName) - \(internship.role) başvurusu için son tarihi kaçırma."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "deadline-\(internship.companyName)-\(internship.role)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Deadline bildirimi planlanamadı: \(error.localizedDescription)")
            }
        }
    }
}
