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

        guard let date = internship.interviewDate else {
            print("Mülakat tarihi yok, bildirim kurulamadı.")
            return
        }
        
        let reminderIntervals = [60, 15, 2]
        let baseIdentifier = internship.companyName + internship.role
        
        for interval in reminderIntervals {
            let content = UNMutableNotificationContent()
            content.title = "Mülakat Hatırlatıcısı: \(internship.companyName)"
            content.subtitle = internship.role
            
            if interval == 60 { content.body = "Mülakatına son 1 saat kaldı! ⏳" }
            else if interval == 15 { content.body = "Sadece 15 dakika kaldı! 💻" }
            else { content.body = "Mülakatın 2 dakika içinde başlıyor! 🚀" }
            
            content.sound = .default
            
            let reminderDate = Calendar.current.date(byAdding: .minute, value: -interval, to: date) ?? date
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            
            print("BİLDİRİM KURULDU: \(interval) dakika öncesi için -> \(components.hour ?? 0):\(components.minute ?? 0)")
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(baseIdentifier)-\(interval)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error { print("Hata: \(error.localizedDescription)") }
            }
        }
    }
    
    func cancelNotification(for internship: Internship) {
        let baseIdentifier = internship.companyName + internship.role
        // Mülakat iptal edilirse, kurulan 3 bildirimi de temizlememiz gerekiyor
        let identifiersToRemove = ["\(baseIdentifier)-60", "\(baseIdentifier)-15", "\(baseIdentifier)-2"]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
}
