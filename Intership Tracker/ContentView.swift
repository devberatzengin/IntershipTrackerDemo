import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            ApplicationsTabView()
                .tabItem { Label("Başvurular", systemImage: "briefcase.fill") }
            CalendarTabView()
                .tabItem { Label("Takvim", systemImage: "calendar.badge.clock") }
            AnalyticsTabView()
                .tabItem { Label("Analitik", systemImage: "chart.bar.fill") }
            ToolsTabView()
                .tabItem { Label("Araçlar", systemImage: "square.grid.2x2.fill") }
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Internship.self, Reference.self, CVDocument.self, NetworkContact.self, InterviewQuestion.self, AppGoal.self, InterviewRound.self, CoverLetter.self], inMemory: true)
}
