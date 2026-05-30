import Testing
import Foundation
@testable import internship_Tracker

struct internship_TrackerTests {

    @Test func testInternshipInitialization() async throws {
        let internship = Internship(
            companyName: "Google",
            role: "iOS Developer Intern",
            workType: .fullTime,
            status: .applied,
            applicationDate: Date(),
            notes: "Mülakat hazırlığı yapılıyor.",
            expectedSalary: "10000",
            applicationDeadline: Date().addingTimeInterval(86400 * 5)
        )
        
        #expect(internship.companyName == "Google")
        #expect(internship.role == "iOS Developer Intern")
        #expect(internship.workType == .fullTime)
        #expect(internship.status == .applied)
        #expect(internship.notes == "Mülakat hazırlığı yapılıyor.")
        #expect(internship.expectedSalary == "10000")
        #expect(internship.daysSinceApplied == 0)
        #expect(internship.isDeadlineNear == false)
    }
    
    @Test func testDaysSinceApplied() async throws {
        // 5 gün öncesini temsil eden tarih
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        let internship = Internship(
            companyName: "Apple",
            role: "SwiftUI Intern",
            applicationDate: pastDate
        )
        
        #expect(internship.daysSinceApplied == 5)
    }

    @Test func testIsDeadlineNear() async throws {
        // Son teslim tarihi 2 gün sonra olan staj
        let nearDeadline = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        let internshipNear = Internship(
            companyName: "Microsoft",
            role: "Developer Intern",
            applicationDeadline: nearDeadline
        )
        #expect(internshipNear.isDeadlineNear == true)
        
        // Son teslim tarihi 10 gün sonra olan staj
        let farDeadline = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        let internshipFar = Internship(
            companyName: "Amazon",
            role: "SDE Intern",
            applicationDeadline: farDeadline
        )
        #expect(internshipFar.isDeadlineNear == false)
    }

    @Test func testRemoteJobDescriptionHTMLCleaning() async throws {
        let job = RemoteJob(
            id: 12345,
            url: "https://remotive.com",
            title: "iOS Engineer",
            companyName: "Acme Corp",
            category: "Software Development",
            jobType: "Full Time",
            publicationDate: "2026-05-30",
            candidateRequiredLocation: "Worldwide",
            salary: "$5000",
            description: "<p>We are looking for a <b>Swift</b> expert &amp; developer.</p>",
            tags: ["ios", "swift"]
        )
        
        #expect(job.cleanedDescription == "We are looking for a Swift expert & developer.")
    }
    
    @Test func testJobUpdateTrackerNewJobsDetection() async throws {
        // Temiz bir test ortamı için UserDefaults sıfırlayalım
        JobUpdateTracker.resetSeenJobsForDemo()
        
        let jobList = [
            RemoteJob(id: 1, url: "https://url1", title: "Job 1", companyName: "C1", category: nil, jobType: nil, publicationDate: nil, candidateRequiredLocation: nil, salary: nil, description: nil, tags: nil),
            RemoteJob(id: 2, url: "https://url2", title: "Job 2", companyName: "C2", category: nil, jobType: nil, publicationDate: nil, candidateRequiredLocation: nil, salary: nil, description: nil, tags: nil)
        ]
        
        // İlk çağrıda database initialize olacağı için 0 bildirim bekliyoruz.
        let newJobsFirstRun = JobUpdateTracker.findNewJobsAndPersist(jobList)
        #expect(newJobsFirstRun.isEmpty)
        
        // İkinci çağrıda yeni bir iş eklenirse, onu "yeni" olarak algılamasını bekliyoruz.
        let updatedJobList = jobList + [
            RemoteJob(id: 3, url: "https://url3", title: "Job 3", companyName: "C3", category: nil, jobType: nil, publicationDate: nil, candidateRequiredLocation: nil, salary: nil, description: nil, tags: nil)
        ]
        
        let newJobsSecondRun = JobUpdateTracker.findNewJobsAndPersist(updatedJobList)
        #expect(newJobsSecondRun.count == 1)
        #expect(newJobsSecondRun.first?.id == 3)
    }
}
