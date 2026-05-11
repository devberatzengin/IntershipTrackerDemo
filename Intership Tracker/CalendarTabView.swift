import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Query(sort: \Internship.interviewDate, order: .forward) private var internships: [Internship]
    
    var upcomingInterviews: [Internship] {
        internships.filter { $0.interviewDate != nil && $0.interviewDate! > Date() }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section with Stats
                    HStack(spacing: 20) {
                        StatMiniCard(title: "Mülakatlar", value: "\(upcomingInterviews.count)", icon: "calendar.badge.clock", color: .indigo)
                        StatMiniCard(title: "Başvurular", value: "\(internships.count)", icon: "briefcase.fill", color: .blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Upcoming Interviews
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Yaklaşan Mülakatlar", systemImage: "clock.badge.checkmark.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                        
                        if upcomingInterviews.isEmpty {
                            EmptyCalendarView()
                        } else {
                            VStack(spacing: 12) {
                                ForEach(upcomingInterviews) { internship in
                                    InterviewCalendarCard(internship: internship)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // All Applications Timeline
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Başvuru Takvimi", systemImage: "list.bullet.indent")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                        
                        ForEach(internships.sorted(by: { $0.applicationDate > $1.applicationDate })) { internship in
                            TimelineRow(internship: internship)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Takvim")
        }
        .fontDesign(.rounded)
    }
}

struct InterviewCalendarCard: View {
    let internship: Internship
    var body: some View {
        NavigationLink(destination: InternshipDetailView(internship: internship)) {
            HStack(spacing: 16) {
                // Date Box
                VStack(spacing: 2) {
                    Text(internship.interviewDate?.formatted(.dateTime.day()) ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(internship.interviewDate?.formatted(.dateTime.month(.abbreviated)) ?? "")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                }
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.accentColor.gradient)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(internship.companyName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(internship.role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(internship.interviewDate?.formatted(date: .omitted, time: .shortened) ?? "")
                    }
                    .font(.caption2)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct TimelineRow: View {
    let internship: Internship
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor(for: internship.status).opacity(0.5))
                .frame(width: 8, height: 8)
            
            Text(internship.applicationDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 85, alignment: .leading)
            
            Text(internship.companyName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            CustomBadge(text: internship.status.rawValue, color: statusColor(for: internship.status))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
        .cornerRadius(12)
    }
}

struct EmptyCalendarView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.accentColor.opacity(0.2))
            Text("Yakınlarda mülakatın yok")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}

struct StatMiniCard: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle().fill(color.opacity(0.1)).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.title3).fontWeight(.bold)
                Text(title).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}
