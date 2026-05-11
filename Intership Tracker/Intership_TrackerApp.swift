import SwiftUI
import SwiftData

@main
struct Intership_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Internship.self, Reference.self, CVDocument.self,
            NetworkContact.self, InterviewQuestion.self, AppGoal.self,
            InterviewRound.self, CoverLetter.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, migrationPlan: InternshipMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("accentColorName") private var accentColorName = "indigo"

    var accentColor: Color {
        switch accentColorName {
        case "blue": return .blue
        case "purple": return .purple
        case "teal": return .teal
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        default: return .indigo
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .tint(accentColor)
            } else {
                OnboardingView()
                    .tint(accentColor)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
