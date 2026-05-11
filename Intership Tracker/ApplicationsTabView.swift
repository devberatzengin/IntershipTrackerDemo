import SwiftUI
import SwiftData

struct ApplicationsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Internship.applicationDate, order: .reverse) private var internships: [Internship]
    @State private var showingAddSheet = false
    @State private var filterStatus: ApplicationStatus? = nil
    @State private var filterTag: String? = nil
    @State private var searchText = ""
    @State private var showingArchived = false
    @State private var isKanbanView = false

    var filteredInternships: [Internship] {
        var result = internships.filter { $0.isArchived == showingArchived }
        if let filterStatus { result = result.filter { $0.status == filterStatus } }
        if let filterTag { result = result.filter { $0.tags.contains(filterTag) } }
        if !searchText.isEmpty {
            result = result.filter { $0.companyName.localizedCaseInsensitiveContains(searchText) || $0.role.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    if !isKanbanView {
                        AnalyticsHeaderView(internships: internships)
                    }
                    
                    if filteredInternships.isEmpty {
                        Spacer(); ContentUnavailableView("Sonuç Bulunamadı", systemImage: "magnifyingglass"); Spacer()
                    } else {
                        if isKanbanView {
                            KanbanBoardView(internships: filteredInternships)
                        } else {
                            List {
                                ForEach(filteredInternships) { i in
                                    ZStack {
                                        InternshipCardView(internship: i)
                                        NavigationLink(destination: InternshipDetailView(internship: i)) { EmptyView() }.opacity(0)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions { Button(role: .destructive) { modelContext.delete(i) } label: { Label("Sil", systemImage: "trash") } }
                                    .swipeActions(edge: .leading) { Button { withAnimation { i.isArchived.toggle() } } label: { Label(i.isArchived ? "Çıkar" : "Arşivle", systemImage: "archivebox") }.tint(.indigo) }
                                }
                            }.listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Başvurular")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Menu {
                            Picker("Durum", selection: $filterStatus) { Text("Tümü").tag(ApplicationStatus?.none); ForEach(ApplicationStatus.allCases, id: \.self) { Text($0.rawValue).tag($0 as ApplicationStatus?) } }
                            Toggle(isOn: $showingArchived) { Label("Arşiv", systemImage: "archivebox") }
                        } label: { Image(systemName: "line.3.horizontal.decrease.circle.fill") }
                        Button { withAnimation { isKanbanView.toggle() } } label: { Image(systemName: isKanbanView ? "list.bullet.circle.fill" : "square.grid.2x2.fill") }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) { Button { showingAddSheet = true } label: { Image(systemName: "plus.circle.fill") } }
            }
            .sheet(isPresented: $showingAddSheet) { AddInternshipView() }
            .onAppear { NotificationManager.instance.requestAuthorization() }
        }
    }
}

struct InternshipDetailView: View {
    @Bindable var internship: Internship
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddRound = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Premium Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(statusColor(for: internship.status).gradient.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Text(String(internship.companyName.prefix(1)).uppercased())
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(statusColor(for: internship.status))
                    }
                    
                    VStack(spacing: 4) {
                        Text(internship.companyName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(internship.role)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    StatusTimelineView(currentStatus: internship.status)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        QuickActionButton(icon: "envelope.fill", color: .blue) {
                            if let url = URL(string: "mailto:\(internship.hrContact)") { UIApplication.shared.open(url) }
                        }
                        QuickActionButton(icon: "safari.fill", color: .indigo) {
                            if let url = URL(string: internship.jobUrl) { UIApplication.shared.open(url) }
                        }
                        QuickActionButton(icon: "square.and.arrow.up.fill", color: .teal) {
                            // Share logic
                        }
                    }
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    // General Info
                    VStack(alignment: .leading, spacing: 12) {
                        PremiumSectionHeader("Genel Bilgiler", icon: "info.circle.fill")
                        VStack(spacing: 0) {
                            DetailRow(title: "Durum", value: internship.status.rawValue, icon: "flag.fill", color: statusColor(for: internship.status))
                            Divider().padding(.leading, 44)
                            DetailRow(title: "Çalışma Türü", value: internship.workType.rawValue, icon: "clock.fill", color: .purple)
                            Divider().padding(.leading, 44)
                            DetailRow(title: "Başvuru Tarihi", value: internship.applicationDate.formatted(date: .long, time: .omitted), icon: "calendar", color: .blue)
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(20)
                    }
                    
                    // Salary & HR
                    VStack(alignment: .leading, spacing: 12) {
                        PremiumSectionHeader("Finans & İletişim", icon: "turkishlirasign.circle.fill")
                        VStack(spacing: 0) {
                            DetailRow(title: "Beklenen Maaş", value: internship.expectedSalary.isEmpty ? "-" : internship.expectedSalary, icon: "banknote.fill", color: .green)
                            if !internship.offeredSalary.isEmpty {
                                Divider().padding(.leading, 44)
                                DetailRow(title: "Teklif Edilen", value: internship.offeredSalary, icon: "checkmark.seal.fill", color: .green)
                            }
                            Divider().padding(.leading, 44)
                            DetailRow(title: "İK Yetkilisi", value: internship.hrContact.isEmpty ? "-" : internship.hrContact, icon: "person.bubble.fill", color: .orange)
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(20)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        PremiumSectionHeader("Notlar", icon: "note.text")
                        TextEditor(text: $internship.notes)
                            .frame(minHeight: 120)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { /* Edit logic */ } label: { Text("Düzenle") }
            }
        }
        .sheet(isPresented: $showingAddRound) { AddInterviewRoundView(internship: internship) }
    }
}

struct QuickActionButton: View {
    let icon: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DetailRow: View {
    let title: String; let value: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.1)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            Text(title).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.semibold)
        }
        .padding(12)
    }
}

struct AddInternshipView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Temel Bilgiler
    @State private var company = ""
    @State private var role = ""
    @State private var workType: WorkType = .internship
    
    // Başvuru Detayları
    @State private var status: ApplicationStatus = .applied
    @State private var applicationDate = Date()
    @State private var jobUrl = ""
    
    // İletişim & Finans
    @State private var hrContact = ""
    @State private var expectedSalary = ""
    
    // Değerlendirme
    @State private var rating = 0
    @State private var notes = ""
    @State private var selectedTags: Set<String> = []
    @State private var applicationDeadline: Date? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        TextField("Şirket İsmi", text: $company)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill.viewfinder")
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        TextField("Pozisyon / Rol", text: $role)
                    }
                    Picker(selection: $workType) {
                        ForEach(WorkType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    } label: {
                        Label("Çalışma Türü", systemImage: "clock.fill")
                    }
                } header: { Text("Genel Bilgiler") }
                
                Section {
                    Picker(selection: $status) {
                        ForEach(ApplicationStatus.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    } label: {
                        Label("Durum", systemImage: "info.circle.fill")
                    }
                    DatePicker(selection: $applicationDate, displayedComponents: .date) {
                        Label("Başvuru Tarihi", systemImage: "calendar")
                    }
                    DatePicker(selection: Binding(get: { applicationDeadline ?? Date() }, set: { applicationDeadline = $0 }), displayedComponents: .date) {
                        Label("Son Başvuru Tarihi", systemImage: "calendar.badge.clock")
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        TextField("Başvuru Linki (URL)", text: $jobUrl)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                } header: { Text("Takip Detayları") }
                
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.bubble.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("İK Yetkilisi / İletişim", text: $hrContact)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "turkishlirasign.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        TextField("Beklenen Maaş", text: $expectedSalary)
                            .keyboardType(.numbersAndPunctuation)
                    }
                } header: { Text("İletişim & Beklenti") }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Öncelik / Beğeni", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        StarRatingView(rating: $rating)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Etiketler", systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(predefinedTags, id: \.self) { tag in
                                    TagChip(label: tag, isSelected: selectedTags.contains(tag), color: .accentColor) {
                                        hapticFeedback(.light)
                                        if selectedTags.contains(tag) { selectedTags.remove(tag) }
                                        else { selectedTags.insert(tag) }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Başvuru notları...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                } header: { Text("Notlar & Değerlendirme") }
            }
            .navigationTitle("Yeni Başvuru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ekle") {
                        hapticFeedback(.soft)
                        let newInternship = Internship(
                            companyName: company,
                            role: role,
                            workType: workType,
                            status: status,
                            applicationDate: applicationDate,
                            notes: notes,
                            jobUrl: jobUrl,
                            hrContact: hrContact,
                            tags: Array(selectedTags),
                            rating: rating,
                            expectedSalary: expectedSalary,
                            applicationDeadline: applicationDeadline
                        )
                        modelContext.insert(newInternship)
                        dismiss()
                    }
                    .disabled(company.isEmpty || role.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct InternshipCardView: View {
    let internship: Internship
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(statusColor(for: internship.status).opacity(0.1))
                        .frame(width: 48, height: 48)
                    Text(String(internship.companyName.prefix(1)).uppercased())
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(statusColor(for: internship.status))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(internship.companyName)
                        .font(.system(.headline, design: .rounded))
                    Text(internship.role)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    CustomBadge(text: internship.status.rawValue, color: statusColor(for: internship.status))
                    if internship.rating > 0 {
                        ReadOnlyStars(rating: internship.rating)
                    }
                }
            }
            
            Divider().opacity(0.5)
            
            HStack {
                Label(internship.applicationDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                Spacer()
                if internship.daysSinceApplied > 0 {
                    Text("\(internship.daysSinceApplied) gündür bekliyor")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                if !internship.offeredSalary.isEmpty {
                    Text(internship.offeredSalary)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                        .font(.system(.subheadline, design: .rounded))
                }
            }
            .font(.system(.caption, design: .rounded))
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

struct KanbanBoardView: View {
    var internships: [Internship]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(ApplicationStatus.allCases, id: \.self) { s in
                    let colApps = internships.filter { $0.status == s }
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(s.rawValue)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(colApps.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor(for: s).opacity(0.1))
                                .foregroundColor(statusColor(for: s))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 4)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(colApps) { i in
                                    NavigationLink(destination: InternshipDetailView(internship: i)) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(i.companyName)
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                            Text(i.role)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            
                                            HStack {
                                                Image(systemName: "calendar")
                                                Text(i.applicationDate.formatted(.dateTime.day().month()))
                                            }
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                        }
                                        .padding(14)
                                        .frame(width: 220, alignment: .leading)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(4)
                        }
                    }
                    .frame(width: 230)
                    .padding(12)
                    .background(statusColor(for: s).opacity(0.03))
                    .cornerRadius(24)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AddInterviewRoundView: View {
    let internship: Internship
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var t = "Teknik"; @State private var o = "Bekliyor"
    var body: some View {
        NavigationStack {
            Form { TextField("Tür", text: $t); TextField("Sonuç", text: $o) }
            .toolbar { Button("Kaydet") { modelContext.insert(InterviewRound(internship: internship, roundType: t, date: Date(), notes: "", outcome: o)); dismiss() } }
        }
    }
}
