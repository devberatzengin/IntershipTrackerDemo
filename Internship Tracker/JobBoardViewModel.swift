import Foundation
import SwiftUI

@MainActor
final class JobBoardViewModel: ObservableObject {
    @Published var jobs: [RemoteJob] = []
    @Published var searchText: String = "internship"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateText: String = "Henüz güncellenmedi"

    private let service = RemoteJobService()

    func loadJobs() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedJobs = try await service.fetchJobs(searchText: searchText)
            jobs = fetchedJobs

            let newJobs = JobUpdateTracker.findNewJobsAndPersist(fetchedJobs)
            if !newJobs.isEmpty {
                NotificationManager.instance.scheduleJobUpdateNotification(
                    count: newJobs.count,
                    firstTitle: newJobs.first?.title
                )
            }

            lastUpdateText = Date.now.formatted(date: .abbreviated, time: .shortened)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func sendDemoNotification() {
        NotificationManager.instance.scheduleProjectNotification(
            title: "Staj takip hatırlatıcısı",
            body: "Yeni ilanları ve yaklaşan başvuru tarihlerini kontrol etmeyi unutma.",
            secondsFromNow: 2
        )
    }

    func resetSeenJobsForDemo() {
        JobUpdateTracker.resetSeenJobsForDemo()
        NotificationManager.instance.scheduleProjectNotification(
            title: "Demo sıfırlandı",
            body: "İlan geçmişi sıfırlandı. Sonraki API güncellemesinde yeni ilan kontrolü yeniden başlayacak.",
            secondsFromNow: 2
        )
    }
}
