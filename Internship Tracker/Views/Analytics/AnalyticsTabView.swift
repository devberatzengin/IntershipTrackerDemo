import SwiftUI
import SwiftData
import Charts

struct AnalyticsTabView: View {
    @Query private var internships: [Internship]
    @AppStorage("lastApplicationDate") private var lastApplicationDateStr = ""
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0

    var activeInternships: [Internship] { internships.filter { !$0.isArchived } }

    var statusCounts: [(status: String, count: Int, color: Color)] {
        ApplicationStatus.allCases.map { s in
            (s.rawValue, activeInternships.filter { $0.status == s }.count, statusColor(for: s))
        }.filter { $0.count > 0 }
    }

    var successRate: Double {
        let t = activeInternships.count; guard t > 0 else { return 0 }
        return Double(activeInternships.filter { $0.status == .offer }.count) / Double(t) * 100
    }

    var interviewRate: Double {
        let t = activeInternships.count; guard t > 0 else { return 0 }
        let i = activeInternships.filter { $0.status == .hrInterview || $0.status == .technicalInterview || $0.status == .finalInterview || $0.status == .offer }.count
        return Double(i) / Double(t) * 100
    }

    var followUpNeeded: [Internship] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return activeInternships.filter { $0.status == .applied && $0.applicationDate <= sevenDaysAgo }
    }

    var monthlyTrend: [(month: String, count: Int)] {
        let cal = Calendar.current; let now = Date()
        return (0..<6).reversed().compactMap { offset -> (String, Int)? in
            guard let date = cal.date(byAdding: .month, value: -offset, to: now) else { return nil }
            let comps = cal.dateComponents([.year, .month], from: date)
            let count = activeInternships.filter {
                let c = cal.dateComponents([.year, .month], from: $0.applicationDate)
                return c.year == comps.year && c.month == comps.month
            }.count
            let fmt = DateFormatter(); fmt.dateFormat = "MMM"; fmt.locale = Locale(identifier: "tr_TR")
            return (fmt.string(from: date), count)
        }
    }

    var topRoles: [(role: String, count: Int)] {
        var d = [String: Int]()
        activeInternships.forEach { d[$0.role, default: 0] += 1 }
        return d.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    var streakCount: Int {
        var streak = 0
        var date = Date()
        let cal = Calendar.current
        while true {
            let hasApp = activeInternships.contains { cal.isDate($0.applicationDate, inSameDayAs: date) }
            if hasApp { streak += 1 } else { break }
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }
    
    var salaryData: (min: Double, max: Double, avg: Double)? {
        let salaries = activeInternships.compactMap { internship -> Double? in
            let targetSalary = internship.offeredSalary.isEmpty ? internship.expectedSalary : internship.offeredSalary
            
            let onlyDigits = targetSalary.filter { $0.isNumber }
            return Double(onlyDigits)
        }.filter { $0 > 0 }
        
        guard !salaries.isEmpty else {
            return (0, 0, 0)
        }
        
        return (salaries.min() ?? 0, salaries.max() ?? 0, salaries.reduce(0, +) / Double(salaries.count))
    }
    
    var velocityTrend: [(week: String, count: Int)] {
        let cal = Calendar.current; let now = Date()
        return (0..<4).reversed().compactMap { offset -> (String, Int)? in
            guard let startOfWeek = cal.date(byAdding: .day, value: -offset * 7, to: now) else { return nil }
            let count = activeInternships.filter {
                let days = cal.dateComponents([.day], from: $0.applicationDate, to: startOfWeek).day ?? 100
                return days >= 0 && days < 7
            }.count
            return ("\(4 - offset). Hafta", count)
        }
    }

    var todayApplied: Bool {
        let cal = Calendar.current
        return activeInternships.contains { cal.isDateInToday($0.applicationDate) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if internships.isEmpty {
                        ContentUnavailableView("Veri Yok", systemImage: "chart.bar.xaxis",
                            description: Text("Analitik verilerini görmek için başvuru ekleyin."))
                            .padding(.top, 100)
                    } else {
                        // Premium Streak Banner
                        StreakBannerView(streak: streakCount, todayApplied: todayApplied)
                            .padding(.horizontal)

                        // Follow-up Alerts
                        if !followUpNeeded.isEmpty {
                            FollowUpAlertCard(applications: followUpNeeded)
                                .padding(.horizontal)
                        }

                        // Summary Statistics
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Toplam Başvuru", value: "\(activeInternships.count)", icon: "briefcase.fill", color: .accentColor, trend: "+12%")
                            StatCard(title: "Mülakat Oranı", value: String(format: "%.0f%%", interviewRate), icon: "person.2.fill", color: .purple, trend: "+5%")
                            StatCard(title: "Teklif Oranı", value: String(format: "%.0f%%", successRate), icon: "checkmark.seal.fill", color: .green, trend: "-2%")
                            StatCard(title: "Bekleyen", value: "\(activeInternships.filter { $0.status == .applied }.count)", icon: "hourglass", color: .orange, trend: "0%")
                        }
                        .padding(.horizontal)

                        // Charts Section
                        VStack(spacing: 24) {
                            // Monthly Trend
                            ChartContainer(title: "Aylık Başvuru Trendi", icon: "chart.line.uptrend.xyaxis") {
                                Chart(monthlyTrend, id: \.month) { item in
                                    BarMark(x: .value("Ay", item.month), y: .value("Adet", item.count), width: .ratio(0.6))
                                        .foregroundStyle(Color.accentColor.gradient)
                                        .cornerRadius(8)
                                }
                                .frame(height: 180)
                            }

                            // Status Donut
                            ChartContainer(title: "Başvuru Dağılımı", icon: "chart.pie.fill") {
                                Chart {
                                    ForEach(statusCounts, id: \.status) { item in
                                        SectorMark(angle: .value("Adet", item.count), innerRadius: .ratio(0.65), angularInset: 2)
                                            .foregroundStyle(item.color.gradient)
                                            .cornerRadius(6)
                                    }
                                }
                                .frame(height: 200)
                                .overlay {
                                    VStack {
                                        Text("\(activeInternships.count)").font(.title).fontWeight(.bold)
                                        Text("Toplam").font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }

                            // Avg Rating
                            let ratedApps = activeInternships.filter { $0.rating > 0 }
                            if !ratedApps.isEmpty {
                                AvgRatingCard(apps: ratedApps)
                            }
                            
                            // Salary Insight
                            if let data = salaryData {
                                ChartContainer(title: "Maaş Analizi", icon: "turkishlirasign.circle.fill") {
                                    SalaryInsightView(data: data)
                                }
                            }
                            
                            // Velocity chart
                            ChartContainer(title: "Başvuru Hızı (Haftalık)", icon: "bolt.fill") {
                                Chart(velocityTrend, id: \.week) { item in
                                    AreaMark(x: .value("Hafta", item.week), y: .value("Adet", item.count))
                                        .foregroundStyle(Color.accentColor.gradient.opacity(0.3))
                                    LineMark(x: .value("Hafta", item.week), y: .value("Adet", item.count))
                                        .foregroundStyle(Color.accentColor)
                                        .symbol(Circle())
                                }
                                .frame(height: 120)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Analitik")
        }
        .fontDesign(.rounded)
    }
}

// MARK: - Premium Streak Banner

struct StreakBannerView: View {
    let streak: Int
    let todayApplied: Bool
    @State private var animate = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.12)).frame(width: 64, height: 64)
                Text(streak > 0 ? "🔥" : "💤")
                    .font(.system(size: 32))
                    .scaleEffect(animate ? 1.2 : 1.0)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(streak > 0 ? "\(streak) GÜNDÜR SERİDESİN!" : "SERİ BOZULDU")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .tracking(1)
                    .foregroundColor(.orange)
                
                Text(todayApplied ? "Bugün başvuru yaptın, harika gidiyorsun! 🚀" : "Hemen bir başvuru yap ve seriyi başlat! 💪")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color(uiColor: .secondarySystemGroupedBackground))
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
            }
        )
        .onAppear {
            if streak > 0 { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { animate = true } }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color; let trend: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon).foregroundColor(color).font(.subheadline)
                Spacer()
                Text(trend).font(.system(size: 10, weight: .bold)).foregroundColor(trend.hasPrefix("+") ? .green : (trend == "0%" ? .secondary : .red))
                    .padding(.horizontal, 6).padding(.vertical, 2).background(Color.secondary.opacity(0.08)).clipShape(Capsule())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.system(size: 28, weight: .bold)).foregroundColor(color)
                Text(title).font(.caption).foregroundColor(.secondary).fontWeight(.medium)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Chart Container

struct ChartContainer<Content: View>: View {
    let title: String; let icon: String; let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon).foregroundColor(.accentColor)
                Text(title).font(.headline).fontWeight(.bold)
            }
            content()
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Avg Rating Card

struct AvgRatingCard: View {
    let apps: [Internship]
    var avgRating: Double { Double(apps.map { $0.rating }.reduce(0, +)) / Double(apps.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.circle.fill").foregroundColor(.yellow)
                Text("Başvuru Memnuniyeti").font(.headline).fontWeight(.bold)
            }
            
            HStack(spacing: 20) {
                Text(String(format: "%.1f", avgRating))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: Double(star) <= avgRating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                    Text("\(apps.count) adet değerlendirilmiş başvuru baz alınmıştır.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
    }
}

// MARK: - Follow Up Alert Card

struct FollowUpAlertCard: View {
    let applications: [Internship]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "bell.badge.fill").foregroundColor(.orange).symbolEffect(.bounce)
                Text("Follow-up Hatırlatıcısı").font(.headline).fontWeight(.bold).foregroundColor(.orange)
                Spacer()
                Text("\(applications.count)").font(.caption).fontWeight(.bold).padding(6).background(Color.orange.opacity(0.1)).foregroundColor(.orange).clipShape(Circle())
            }
            
            Text("Aşağıdaki şirketlerden 7 gündür haber yok. Bir mesaj atmak iyi bir fikir olabilir.")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            VStack(spacing: 8) {
                ForEach(applications.prefix(2)) { app in
                    HStack {
                        Circle().fill(Color.orange.opacity(0.1)).frame(width: 32, height: 32)
                            .overlay(Text(String(app.companyName.prefix(1))).font(.caption).fontWeight(.bold).foregroundColor(.orange))
                        Text(app.companyName).font(.subheadline).fontWeight(.medium)
                        Spacer()
                        Text(app.applicationDate, style: .relative).font(.caption2).foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color.orange.opacity(0.02))
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.orange.opacity(0.1), lineWidth: 1)
            }
        )
    }
}
// MARK: - Salary Insight View

struct SalaryInsightView: View {
    let data: (min: Double, max: Double, avg: Double)
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                InsightBox(title: "En Düşük", value: String(format: "%.0f", data.min), color: .orange)
                InsightBox(title: "Ortalama", value: String(format: "%.0f", data.avg), color: .blue)
                InsightBox(title: "En Yüksek", value: String(format: "%.0f", data.max), color: .green)
            }
            
            Chart {
                BarMark(x: .value("Tip", "Minimum"), y: .value("Maaş", data.min))
                    .foregroundStyle(Color.orange.gradient)
                BarMark(x: .value("Tip", "Ortalama"), y: .value("Maaş", data.avg))
                    .foregroundStyle(Color.blue.gradient)
                BarMark(x: .value("Tip", "Maksimum"), y: .value("Maaş", data.max))
                    .foregroundStyle(Color.green.gradient)
            }
            .frame(height: 100)
            .chartXAxis(.hidden)
        }
    }
}

struct InsightBox: View {
    let title: String; let value: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}
