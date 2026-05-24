import Foundation
import SwiftData

// MARK: - V1

enum InternshipSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Internship.self] }

    @Model final class Internship {
        var companyName: String; var role: String; var workType: WorkType
        var status: ApplicationStatus; var applicationDate: Date; var notes: String
        var jobUrl: String; var hrContact: String; var isArchived: Bool
        var interviewDate: Date?; var remindMe: Bool
        init(companyName: String, role: String, workType: WorkType = .internship, status: ApplicationStatus = .notOpen, applicationDate: Date = Date(), notes: String = "", jobUrl: String = "", hrContact: String = "", isArchived: Bool = false, interviewDate: Date? = nil, remindMe: Bool = false) {
            self.companyName = companyName; self.role = role; self.workType = workType
            self.status = status; self.applicationDate = applicationDate; self.notes = notes
            self.jobUrl = jobUrl; self.hrContact = hrContact; self.isArchived = isArchived
            self.interviewDate = interviewDate; self.remindMe = remindMe
        }
    }
}

// MARK: - V2

enum InternshipSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    static var models: [any PersistentModel.Type] { [Internship.self, Reference.self, CVDocument.self] }

    @Model final class Internship {
        var companyName: String; var role: String; var workType: WorkType
        var status: ApplicationStatus; var applicationDate: Date; var notes: String
        var interviewPrepNotes: String = ""; var jobUrl: String; var hrContact: String
        var isArchived: Bool; var interviewDate: Date?; var remindMe: Bool
        init(companyName: String, role: String, workType: WorkType = .internship, status: ApplicationStatus = .notOpen, applicationDate: Date = Date(), notes: String = "", interviewPrepNotes: String = "", jobUrl: String = "", hrContact: String = "", isArchived: Bool = false, interviewDate: Date? = nil, remindMe: Bool = false) {
            self.companyName = companyName; self.role = role; self.workType = workType
            self.status = status; self.applicationDate = applicationDate; self.notes = notes
            self.interviewPrepNotes = interviewPrepNotes; self.jobUrl = jobUrl
            self.hrContact = hrContact; self.isArchived = isArchived
            self.interviewDate = interviewDate; self.remindMe = remindMe
        }
    }
    @Model final class Reference {
        var name: String; var title: String; var company: String
        var email: String; var phone: String; var notes: String
        init(name: String, title: String, company: String, email: String, phone: String, notes: String = "") {
            self.name = name; self.title = title; self.company = company
            self.email = email; self.phone = phone; self.notes = notes
        }
    }
    @Model final class CVDocument {
        var name: String; var fileData: Data; var createdAt: Date
        init(name: String, fileData: Data, createdAt: Date = Date()) {
            self.name = name; self.fileData = fileData; self.createdAt = createdAt
        }
    }
}

// MARK: - V3

enum InternshipSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 2, 0)
    static var models: [any PersistentModel.Type] { [Internship.self, Reference.self, CVDocument.self, NetworkContact.self] }

    @Model final class Internship {
        var companyName: String; var role: String; var workType: WorkType
        var status: ApplicationStatus; var applicationDate: Date; var notes: String
        var interviewPrepNotes: String = ""; var jobUrl: String; var hrContact: String
        var isArchived: Bool; var interviewDate: Date?; var remindMe: Bool
        init(companyName: String, role: String, workType: WorkType = .internship, status: ApplicationStatus = .notOpen, applicationDate: Date = Date(), notes: String = "", interviewPrepNotes: String = "", jobUrl: String = "", hrContact: String = "", isArchived: Bool = false, interviewDate: Date? = nil, remindMe: Bool = false) {
            self.companyName = companyName; self.role = role; self.workType = workType
            self.status = status; self.applicationDate = applicationDate; self.notes = notes
            self.interviewPrepNotes = interviewPrepNotes; self.jobUrl = jobUrl
            self.hrContact = hrContact; self.isArchived = isArchived
            self.interviewDate = interviewDate; self.remindMe = remindMe
        }
    }
    @Model final class Reference {
        var name: String; var title: String; var company: String
        var email: String; var phone: String; var notes: String
        init(name: String, title: String, company: String, email: String, phone: String, notes: String = "") {
            self.name = name; self.title = title; self.company = company
            self.email = email; self.phone = phone; self.notes = notes
        }
    }
    @Model final class CVDocument {
        var name: String; var fileData: Data; var createdAt: Date
        init(name: String, fileData: Data, createdAt: Date = Date()) {
            self.name = name; self.fileData = fileData; self.createdAt = createdAt
        }
    }
    @Model final class NetworkContact {
        var name: String; var company: String; var role: String
        var email: String; var phone: String; var linkedinUrl: String
        var lastContactDate: Date; var notes: String
        init(name: String, company: String, role: String = "", email: String = "", phone: String = "", linkedinUrl: String = "", lastContactDate: Date = Date(), notes: String = "") {
            self.name = name; self.company = company; self.role = role
            self.email = email; self.phone = phone; self.linkedinUrl = linkedinUrl
            self.lastContactDate = lastContactDate; self.notes = notes
        }
    }
}

// MARK: - V4

enum InternshipSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 3, 0)
    static var models: [any PersistentModel.Type] { [Internship.self, Reference.self, CVDocument.self, NetworkContact.self, InterviewQuestion.self, AppGoal.self] }

    @Model final class Internship {
        var companyName: String; var role: String; var workType: WorkType
        var status: ApplicationStatus; var applicationDate: Date; var notes: String
        var interviewPrepNotes: String = ""; var jobUrl: String; var hrContact: String
        var isArchived: Bool; var interviewDate: Date?; var remindMe: Bool
        var tags: [String] = []
        init(companyName: String, role: String, workType: WorkType = .internship, status: ApplicationStatus = .notOpen, applicationDate: Date = Date(), notes: String = "", interviewPrepNotes: String = "", jobUrl: String = "", hrContact: String = "", isArchived: Bool = false, interviewDate: Date? = nil, remindMe: Bool = false, tags: [String] = []) {
            self.companyName = companyName; self.role = role; self.workType = workType
            self.status = status; self.applicationDate = applicationDate; self.notes = notes
            self.interviewPrepNotes = interviewPrepNotes; self.jobUrl = jobUrl
            self.hrContact = hrContact; self.isArchived = isArchived
            self.interviewDate = interviewDate; self.remindMe = remindMe; self.tags = tags
        }
    }
    @Model final class Reference {
        var name: String; var title: String; var company: String
        var email: String; var phone: String; var notes: String
        init(name: String, title: String, company: String, email: String, phone: String, notes: String = "") {
            self.name = name; self.title = title; self.company = company
            self.email = email; self.phone = phone; self.notes = notes
        }
    }
    @Model final class CVDocument {
        var name: String; var fileData: Data; var createdAt: Date
        init(name: String, fileData: Data, createdAt: Date = Date()) {
            self.name = name; self.fileData = fileData; self.createdAt = createdAt
        }
    }
    @Model final class NetworkContact {
        var name: String; var company: String; var role: String
        var email: String; var phone: String; var linkedinUrl: String
        var lastContactDate: Date; var notes: String
        init(name: String, company: String, role: String = "", email: String = "", phone: String = "", linkedinUrl: String = "", lastContactDate: Date = Date(), notes: String = "") {
            self.name = name; self.company = company; self.role = role
            self.email = email; self.phone = phone; self.linkedinUrl = linkedinUrl
            self.lastContactDate = lastContactDate; self.notes = notes
        }
    }
    @Model final class InterviewQuestion {
        var question: String; var answer: String; var category: String; var createdAt: Date
        init(question: String, answer: String = "", category: String = "Genel", createdAt: Date = Date()) {
            self.question = question; self.answer = answer; self.category = category; self.createdAt = createdAt
        }
    }
    @Model final class AppGoal {
        var targetCount: Int; var period: String; var startDate: Date; var createdAt: Date
        init(targetCount: Int, period: String = "monthly", startDate: Date = Date(), createdAt: Date = Date()) {
            self.targetCount = targetCount; self.period = period; self.startDate = startDate; self.createdAt = createdAt
        }
    }
}

// MARK: - V5 (Current)

enum InternshipSchemaV5: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 4, 0)
    static var models: [any PersistentModel.Type] {
        [Internship.self, Reference.self, CVDocument.self, NetworkContact.self,
         InterviewQuestion.self, AppGoal.self, InterviewRound.self, CoverLetter.self]
    }

    @Model final class Internship {
        var companyName: String
        var role: String
        var workType: WorkType
        var status: ApplicationStatus
        var applicationDate: Date
        var notes: String
        var interviewPrepNotes: String = ""
        var jobUrl: String
        var hrContact: String
        var isArchived: Bool
        var interviewDate: Date?
        var remindMe: Bool
        var tags: [String] = []
        var rating: Int = 0 
        var expectedSalary: String = ""
        var offeredSalary: String = ""
        var companyNote: String = ""
        var applicationDeadline: Date?
        
        var daysSinceApplied: Int {
            Calendar.current.dateComponents([.day], from: applicationDate, to: Date()).day ?? 0
        }
        
        var isDeadlineNear: Bool {
            guard let deadline = applicationDeadline else { return false }
            let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 100
            return days >= 0 && days <= 3
        }
        
        @Relationship(deleteRule: .cascade, inverse: \InterviewRound.internship)
        var interviewRounds: [InterviewRound] = []

        init(companyName: String, role: String, workType: WorkType = .internship,
             status: ApplicationStatus = .notOpen, applicationDate: Date = Date(),
             notes: String = "", interviewPrepNotes: String = "", jobUrl: String = "",
             hrContact: String = "", isArchived: Bool = false, interviewDate: Date? = nil,
             remindMe: Bool = false, tags: [String] = [], rating: Int = 0,
             expectedSalary: String = "", offeredSalary: String = "", companyNote: String = "",
             applicationDeadline: Date? = nil) {
            self.companyName = companyName; self.role = role; self.workType = workType
            self.status = status; self.applicationDate = applicationDate; self.notes = notes
            self.interviewPrepNotes = interviewPrepNotes; self.jobUrl = jobUrl
            self.hrContact = hrContact; self.isArchived = isArchived
            self.interviewDate = interviewDate; self.remindMe = remindMe
            self.tags = tags; self.rating = rating
            self.expectedSalary = expectedSalary; self.offeredSalary = offeredSalary
            self.companyNote = companyNote; self.applicationDeadline = applicationDeadline
        }
    }

    @Model final class Reference {
        var name: String; var title: String; var company: String
        var email: String; var phone: String; var notes: String
        init(name: String, title: String, company: String, email: String, phone: String, notes: String = "") {
            self.name = name; self.title = title; self.company = company
            self.email = email; self.phone = phone; self.notes = notes
        }
    }

    @Model final class CVDocument {
        var name: String; var fileData: Data; var uploadDate: Date
        init(name: String, fileData: Data, uploadDate: Date = Date()) {
            self.name = name; self.fileData = fileData; self.uploadDate = uploadDate
        }
    }

    @Model final class NetworkContact {
        var name: String; var company: String; var role: String
        var email: String; var phone: String; var linkedinUrl: String
        var lastContactDate: Date; var notes: String
        init(name: String, company: String, role: String = "", email: String = "", phone: String = "", linkedinUrl: String = "", lastContactDate: Date = Date(), notes: String = "") {
            self.name = name; self.company = company; self.role = role
            self.email = email; self.phone = phone; self.linkedinUrl = linkedinUrl
            self.lastContactDate = lastContactDate; self.notes = notes
        }
    }

    @Model final class InterviewQuestion {
        var question: String; var answer: String; var category: String; var createdAt: Date
        init(question: String, answer: String = "", category: String = "Genel", createdAt: Date = Date()) {
            self.question = question; self.answer = answer; self.category = category; self.createdAt = createdAt
        }
    }

    @Model final class AppGoal {
        var title: String
        var targetCount: Int
        var currentCount: Int
        var period: String
        var startDate: Date
        var createdAt: Date

        init(title: String, targetCount: Int, currentCount: Int = 0, period: String = "Haftalık", startDate: Date = Date(), createdAt: Date = Date()) {
            self.title = title
            self.targetCount = targetCount
            self.currentCount = currentCount
            self.period = period
            self.startDate = startDate
            self.createdAt = createdAt
        }
    }

    @Model final class InterviewRound {
        var internship: Internship?
        var roundType: String         // "İK Mülakatı", "Teknik", "Son Mülakat", "Vaka Çalışması", "Diğer"
        var date: Date
        var notes: String
        var outcome: String           // "Bekleniyor", "Geçti", "Kaldı"
        var createdAt: Date

        init(internship: Internship? = nil, roundType: String = "İK Mülakatı", date: Date = Date(), notes: String = "", outcome: String = "Bekleniyor", createdAt: Date = Date()) {
            self.internship = internship; self.roundType = roundType
            self.date = date; self.notes = notes; self.outcome = outcome; self.createdAt = createdAt
        }
    }

    @Model final class CoverLetter {
        var title: String
        var targetRole: String
        var content: String
        var createdAt: Date

        init(title: String, targetRole: String = "", content: String = "", createdAt: Date = Date()) {
            self.title = title; self.targetRole = targetRole
            self.content = content; self.createdAt = createdAt
        }
    }
}

// MARK: - Migration Plan

enum InternshipMigrationPlan: SchemaMigrationPlan {
    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4, migrateV4toV5]
    }
    static var schemas: [any VersionedSchema.Type] {
        [InternshipSchemaV1.self, InternshipSchemaV2.self, InternshipSchemaV3.self,
         InternshipSchemaV4.self, InternshipSchemaV5.self]
    }
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: InternshipSchemaV1.self, toVersion: InternshipSchemaV2.self,
        willMigrate: { _ in },
        didMigrate: { context in
            let internships = try context.fetch(FetchDescriptor<InternshipSchemaV2.Internship>())
            for i in internships { if i.interviewPrepNotes.isEmpty { i.interviewPrepNotes = "" } }
            try context.save()
        }
    )
    static let migrateV2toV3 = MigrationStage.lightweight(fromVersion: InternshipSchemaV2.self, toVersion: InternshipSchemaV3.self)
    static let migrateV3toV4 = MigrationStage.lightweight(fromVersion: InternshipSchemaV3.self, toVersion: InternshipSchemaV4.self)
    static let migrateV4toV5 = MigrationStage.lightweight(fromVersion: InternshipSchemaV4.self, toVersion: InternshipSchemaV5.self)
}

// MARK: - Global Typealiases

typealias Internship = InternshipSchemaV5.Internship
typealias Reference = InternshipSchemaV5.Reference
typealias CVDocument = InternshipSchemaV5.CVDocument
typealias NetworkContact = InternshipSchemaV5.NetworkContact
typealias InterviewQuestion = InternshipSchemaV5.InterviewQuestion
typealias AppGoal = InternshipSchemaV5.AppGoal
typealias InterviewRound = InternshipSchemaV5.InterviewRound
typealias CoverLetter = InternshipSchemaV5.CoverLetter

// MARK: - Enums

enum ApplicationStatus: String, Codable, CaseIterable {
    case notOpen = "Henüz Açılmadı"
    case applied = "Başvuruldu"
    case hrInterview = "İK Mülakatı"
    case technicalInterview = "Teknik Mülakat"
    case finalInterview = "Son Mülakat"
    case offer = "Teklif Alındı"
    case rejected = "Reddedildi"
    case withdrawn = "Geri Çekildi"
}

enum WorkType: String, Codable, CaseIterable {
    case internship = "Stajyer"
    case partTime = "Yarı Zamanlı"
    case fullTime = "Tam Zamanlı"
    case freelance = "Freelance"
}

// Predefined tags
let predefinedTags = ["Uzaktan", "Hibrit", "Ofis", "Yeni Mezun", "Deneyimli", "Acil", "Referanslı", "Favori"]
