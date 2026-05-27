import Foundation

enum JobUpdateTracker {
    private static let seenJobIDsKey = "seenRemotiveJobIDs"
    private static let hasInitializedKey = "hasInitializedRemotiveJobs"

    static func findNewJobsAndPersist(_ jobs: [RemoteJob]) -> [RemoteJob] {
        let defaults = UserDefaults.standard
        let currentIDs = Set(jobs.map { $0.id })
        let oldIDs = Set(defaults.array(forKey: seenJobIDsKey) as? [Int] ?? [])
        let hasInitialized = defaults.bool(forKey: hasInitializedKey)

        defaults.set(Array(currentIDs.union(oldIDs)), forKey: seenJobIDsKey)
        defaults.set(true, forKey: hasInitializedKey)

        // İlk açılışta yüzlerce eski ilan için bildirim yağdırmayalım.
        guard hasInitialized else {
            return []
        }

        let newIDs = currentIDs.subtracting(oldIDs)
        return jobs.filter { newIDs.contains($0.id) }
    }

    static func resetSeenJobsForDemo() {
        // Demo için "daha önce hiç ilan görmemişiz" gibi davranmak istiyoruz.
        // Bu yüzden initialized true kalır, seen list boşaltılır.
        UserDefaults.standard.set([], forKey: seenJobIDsKey)
        UserDefaults.standard.set(true, forKey: hasInitializedKey)
    }
}
