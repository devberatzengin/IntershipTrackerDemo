import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success { print("Bildirim izni alındı") }
            else if let error = error { print(error.localizedDescription) }
        }
    }
    
    func scheduleInterviewNotification(for internship: Internship) {
        guard let date = internship.interviewDate, internship.remindMe else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Mülakat Hatırlatıcısı: \(internship.companyName)"
        content.subtitle = internship.role
        content.body = "Mülakatın birazdan başlıyor! Hazır mısın? 🚀"
        content.sound = .default
        
        // Reminder 30 minutes before
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -30, to: date) ?? date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: internship.companyName + internship.role, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for internship: Internship) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [internship.companyName + internship.role])
    }
}
