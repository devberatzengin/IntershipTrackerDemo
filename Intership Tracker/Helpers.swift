import SwiftUI
import UserNotifications

// MARK: - App Colors

func statusColor(for status: ApplicationStatus) -> Color {
    switch status {
    case .notOpen: return .gray
    case .applied: return .blue
    case .hrInterview: return .purple
    case .technicalInterview: return .orange
    case .finalInterview: return .pink
    case .offer: return .green
    case .rejected: return .red
    case .withdrawn: return .brown
    }
}

// MARK: - Common UI Components

struct AnalyticsHeaderView: View {
    let internships: [Internship]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatBox(title: "Toplam", count: internships.count, icon: "briefcase.fill", color: .blue)
                StatBox(title: "Mülakat", count: internships.filter { [.hrInterview, .technicalInterview, .finalInterview].contains($0.status) }.count, icon: "person.2.fill", color: .orange)
                StatBox(title: "Teklif", count: internships.filter { $0.status == .offer }.count, icon: "checkmark.seal.fill", color: .green)
                StatBox(title: "Red/Çekildi", count: internships.filter { [.rejected, .withdrawn].contains($0.status) }.count, icon: "xmark.circle.fill", color: .red)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct StatBox: View {
    let title: String; let count: Int; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon).foregroundColor(color).font(.caption)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)").font(.title2).fontWeight(.bold).foregroundColor(.primary)
                Text(title).font(.system(size: 10, weight: .semibold)).foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(minWidth: 100, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


struct StarRatingView: View {
    @Binding var rating: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.2))
                    .onTapGesture {
                        UISelectionFeedbackGenerator().selectionChanged()
                        rating = rating == star ? 0 : star
                    }
            }
        }
        .font(.title3)
    }
}

struct ReadOnlyStars: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.15))
            }
        }
    }
}

struct TagChip: View {
    let label: String; let isSelected: Bool; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label).font(.caption).fontWeight(.medium)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundColor(isSelected ? .white : color)
                .clipShape(Capsule())
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: activityItems, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Utilities

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(type)
}

// MARK: - Premium UI Components

struct PremiumSectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1)
        }
        .foregroundColor(.secondary)
        .padding(.leading, 8)
        .padding(.bottom, 4)
    }
}

struct StatusTimelineView: View {
    let currentStatus: ApplicationStatus
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(ApplicationStatus.allCases.prefix(6).enumerated()), id: \.offset) { index, status in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(isReached(status) ? statusColor(for: status) : Color.secondary.opacity(0.2))
                            .frame(width: 12, height: 12)
                        
                        if status == currentStatus {
                            Circle()
                                .stroke(statusColor(for: status).opacity(0.3), lineWidth: 4)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    Text(shortLabel(for: status))
                        .font(.system(size: 8, weight: isReached(status) ? .bold : .medium))
                        .foregroundColor(isReached(status) ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
                
                if index < 5 {
                    Rectangle()
                        .fill(isReached(ApplicationStatus.allCases[index + 1]) ? statusColor(for: ApplicationStatus.allCases[index + 1]).opacity(0.5) : Color.secondary.opacity(0.1))
                        .frame(height: 2)
                        .offset(y: -9)
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private func isReached(_ status: ApplicationStatus) -> Bool {
        let all = ApplicationStatus.allCases
        guard let currentIndex = all.firstIndex(of: currentStatus),
              let targetIndex = all.firstIndex(of: status) else { return false }
        return targetIndex <= currentIndex
    }
    
    private func shortLabel(for status: ApplicationStatus) -> String {
        switch status {
        case .notOpen: return "Başla"
        case .applied: return "Başvuru"
        case .hrInterview: return "İK"
        case .technicalInterview: return "Teknik"
        case .finalInterview: return "Son"
        case .offer: return "Teklif"
        default: return ""
        }
    }
}

struct CustomBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
