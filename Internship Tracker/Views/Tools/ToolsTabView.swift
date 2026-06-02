import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Combine

struct ToolsTabView: View {
    @Query private var internships: [Internship]
    @State private var showingExportShareSheet = false
    @State private var exportURL: URL?
    @State private var showingPDFShare = false
    @State private var pdfURL: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    ToolSection(title: "Profesyonel Araçlar") {
                        VStack(spacing: 0) {
                            NavigationLink(destination: NetworkingView()) {
                                ToolRow(icon: "person.2.wave.2.fill", color: .blue, title: "Networking", description: "Bağlantılarını ve etkinlikleri yönet")
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: ReferencesView()) {
                                ToolRow(icon: "star.bubble.fill", color: .purple, title: "Referanslarım", description: "Profesyonel referans listesi")
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: EmailTemplatesView()) {
                                ToolRow(icon: "envelope.badge.shield.fill", color: .orange, title: "E-posta Şablonları", description: "Hazır mülakat ve teklif mesajları")
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: CoverLetterView()) {
                                ToolRow(icon: "doc.append.fill", color: .indigo, title: "Niyet Mektupları", description: "Özelleştirilebilir şablonlar")
                            }
                        }
                    }
                    
                    ToolSection(title: "Gelişim & Takip") {
                        VStack(spacing: 0) {
                            NavigationLink(destination: InterviewPrepView()) {
                                ToolRow(icon: "brain.head.profile.fill", color: .pink, title: "Mülakat Hazirlik", description: "Soru bankası ve notlar")
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: GoalSettingView()) {
                                ToolRow(icon: "target", color: .red, title: "Başvuru Hedeflerim", description: "Haftalık ve aylık hedefler")
                            }
                            Divider().padding(.leading, 56)
                            NavigationLink(destination: CVManagementView()) {
                                ToolRow(icon: "doc.richtext.fill", color: .teal, title: "Özgeçmişlerim (CV)", description: "Tüm CV versiyonlarını sakla")
                            }
                        }
                    }
                    
                    ToolSection(title: "Dışa Aktarma") {
                        VStack(spacing: 0) {
                            Button(action: { hapticFeedback(.light); exportApplicationsToCSV() }) {
                                ToolRow(icon: "tablecells.fill", color: .green, title: "Excel (CSV) Aktar", description: "Verilerini tablo olarak paylaş")
                            }
                            Divider().padding(.leading, 56)
                            Button(action: { hapticFeedback(.light); exportToPDF() }) {
                                ToolRow(icon: "doc.badge.arrow.up.fill", color: .blue, title: "PDF Başvuru Raporu", description: "Profesyonel özet rapor oluştur")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Araçlar")
        .sheet(isPresented: $showingExportShareSheet) { if let url = exportURL { ShareSheet(activityItems: [url]) } }
        .sheet(isPresented: $showingPDFShare) { if let url = pdfURL { ShareSheet(activityItems: [url]) } }
        .fontDesign(.rounded)
    }

    private func exportApplicationsToCSV() {
        var csv = "Şirket,Rol,Tür,Durum,Tarih,Puan,Beklenen Maaş,Teklif Maaş,Etiketler,Notlar\n"
        let fmt = DateFormatter(); fmt.dateStyle = .short
        for i in internships {
            csv += "\"\(i.companyName)\",\"\(i.role)\",\(i.workType.rawValue),\(i.status.rawValue),\(fmt.string(from: i.applicationDate)),\(i.rating),\(i.expectedSalary),\(i.offeredSalary),\"\(i.tags.joined(separator: ";"))\",\"\(i.notes.replacingOccurrences(of: "\n", with: " "))\"\n"
        }
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("Basvurularim.csv")
        try? csv.write(to: path, atomically: true, encoding: .utf8)
        exportURL = path; showingExportShareSheet = true
    }

    private func exportToPDF() {
        let fmt = DateFormatter(); fmt.dateStyle = .medium
        let pageWidth: CGFloat = 595.2; let pageHeight: CGFloat = 841.8; let margin: CGFloat = 40
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let data = pdfRenderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margin
            let titleAttr: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.systemIndigo]
            "Başvuru Raporu".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttr); y += 30
            let dateAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.secondaryLabel]
            "Oluşturulma: \(fmt.string(from: Date()))".draw(at: CGPoint(x: margin, y: y), withAttributes: dateAttr); y += 20
            let summaryAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.label]
            "Toplam \(internships.count) başvuru".draw(at: CGPoint(x: margin, y: y), withAttributes: summaryAttr); y += 30
            UIColor.separator.setStroke()
            let line = UIBezierPath(); line.move(to: CGPoint(x: margin, y: y)); line.addLine(to: CGPoint(x: pageWidth - margin, y: y)); line.stroke(); y += 16
            let rowAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.label]
            let subAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.secondaryLabel]
            for internship in internships {
                if y > pageHeight - 80 { ctx.beginPage(); y = margin }
                let companyStr = "\(internship.companyName) — \(internship.role)"
                companyStr.draw(at: CGPoint(x: margin, y: y), withAttributes: rowAttr); y += 16
                let detailStr = "\(internship.status.rawValue) | \(fmt.string(from: internship.applicationDate)) | Puan: \(String(repeating: "★", count: internship.rating))"
                detailStr.draw(at: CGPoint(x: margin + 8, y: y), withAttributes: subAttr); y += 20
            }
        }
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("BasvuruRaporu.pdf")
        try? data.write(to: path); pdfURL = path; showingPDFShare = true
    }
}

// MARK: - Detailed Tool Views

struct NetworkingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NetworkContact.lastContactDate, order: .reverse) private var contacts: [NetworkContact]
    @State private var showingAdd = false
    var body: some View {
        List {
            if contacts.isEmpty {
                ContentUnavailableView("Bağlantı Yok", systemImage: "person.2.badge.gearshape.fill", description: Text("Henüz bir networking bağlantısı eklemediniz."))
                    .padding(.top, 40)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(contacts, id: \.self) { contact in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                Text(String(contact.name.prefix(1)).uppercased())
                                    .font(.title3).fontWeight(.bold).foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name).font(.headline)
                                Text("\(contact.role) @ \(contact.company)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if !contact.linkedinUrl.isEmpty {
                                Link(destination: URL(string: contact.linkedinUrl) ?? URL(string: "https://linkedin.com")!) {
                                    Image(systemName: "link.circle.fill")
                                        .font(.title2)
                                        .symbolRenderingMode(.multicolor)
                                }
                            }
                        }
                        
                        if !contact.notes.isEmpty {
                            Text(contact.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.05))
                                .cornerRadius(8)
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill").font(.caption2)
                            Text("Son İletişim: \(contact.lastContactDate.formatted(date: .abbreviated, time: .omitted))")
                            Spacer()
                            Button {
                                // Add quick follow-up log or reminder
                                hapticFeedback(.light)
                            } label: {
                                Text("Hatırlatıcı")
                                    .font(.caption2).fontWeight(.bold)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(Color.blue)
                                    .cornerRadius(6)
                            }
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                    .swipeActions {
                        Button(role: .destructive) { modelContext.delete(contact) } label: { Label("Sil", systemImage: "trash") }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Networking")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) { AddContactView() }
    }
}

struct AddContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""; @State private var company = ""; @State private var role = ""; @State private var linkedin = ""; @State private var notes = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Kişi Seç") { TextField("İsim", text: $name).fontWeight(.bold); TextField("Şirket", text: $company); TextField("Pozisyon", text: $role) }
                Section("Bağlantı") { TextField("LinkedIn URL", text: $linkedin).textInputAutocapitalization(.never) }
                Section("Notlar") { TextEditor(text: $notes).frame(minHeight: 100) }
            }
            .navigationTitle("Yeni Kişi")
            .toolbar { Button("Ekle") { modelContext.insert(NetworkContact(name: name, company: company, role: role, linkedinUrl: linkedin, notes: notes)); dismiss() }.disabled(name.isEmpty) }
        }
    }
}

struct ReferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reference.name) private var references: [Reference]
    @State private var showingAdd = false
    var body: some View {
        List {
            if references.isEmpty {
                ContentUnavailableView("Referans Yok", systemImage: "star.bubble.fill", description: Text("Eklediğiniz referanslar burada görünecek."))
                    .padding(.top, 40)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(references, id: \.self) { ref in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle().fill(Color.purple.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                    .font(.title3).foregroundColor(.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ref.name).font(.headline)
                                Text("\(ref.title) @ \(ref.company)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 15) {
                                Button {
                                    UIPasteboard.general.string = ref.email
                                    hapticFeedback(.light)
                                } label: {
                                    Image(systemName: "envelope.circle.fill")
                                        .font(.title2)
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.blue)
                                }
                                
                                if !ref.phone.isEmpty {
                                    Button {
                                        if let url = URL(string: "tel://\(ref.phone)") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        Image(systemName: "phone.circle.fill")
                                            .font(.title2)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        if !ref.notes.isEmpty {
                            Text(ref.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.05))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                    .swipeActions {
                        Button(role: .destructive) { modelContext.delete(ref) } label: { Label("Sil", systemImage: "trash") }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Referanslarım")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) { AddReferenceView() }
    }
}

struct AddReferenceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""; @State private var company = ""; @State private var title = ""; @State private var email = ""; @State private var phone = ""; @State private var notes = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Temel Bilgiler") { TextField("İsim", text: $name).fontWeight(.bold); TextField("Şirket", text: $company); TextField("Ünvan", text: $title) }
                Section("İletişim") { TextField("E-posta", text: $email).textInputAutocapitalization(.never); TextField("Telefon", text: $phone).keyboardType(.phonePad) }
                Section("Notlar") { TextEditor(text: $notes).frame(minHeight: 80) }
            }
            .navigationTitle("Yeni Referans")
            .toolbar { Button("Ekle") { modelContext.insert(Reference(name: name, title: title, company: company, email: email, phone: phone, notes: notes)); dismiss() }.disabled(name.isEmpty) }
        }
    }
}

struct GoalSettingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppGoal.createdAt, order: .reverse) private var goals: [AppGoal]
    @State private var showingAdd = false
    var body: some View {
        List {
            ForEach(goals) { goal in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) { Text(goal.title).font(.headline); Text("\(goal.period) • Başlangıç: \(goal.startDate.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundColor(.secondary) }
                        Spacer()
                        Text("\(goal.currentCount)/\(goal.targetCount)").font(.headline).fontWeight(.bold).foregroundColor(goal.currentCount >= goal.targetCount ? .green : .accentColor)
                    }
                    ProgressView(value: Double(goal.currentCount), total: Double(goal.targetCount)).tint(goal.currentCount >= goal.targetCount ? .green : .accentColor)
                    HStack {
                        Button { withAnimation { goal.currentCount = max(0, goal.currentCount - 1) } } label: { Image(systemName: "minus.circle.fill").foregroundColor(.secondary) }
                        Spacer()
                        Button { withAnimation { goal.currentCount += 1 } } label: { Image(systemName: "plus.circle.fill").foregroundColor(.accentColor) }
                    }.buttonStyle(.plain).font(.title3)
                }
                .padding(.vertical, 8)
                .swipeActions { Button(role: .destructive) { modelContext.delete(goal) } label: { Label("Sil", systemImage: "trash") } }
            }
        }
        .navigationTitle("Hedeflerim")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) { AddGoalView() }
    }
}

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var t = ""; @State private var target = 10; @State private var p = "Haftalık"
    var body: some View {
        NavigationStack {
            Form {
                TextField("Hedef İsmi", text: $t); Picker("Periyot", selection: $p) { ForEach(["Haftalık", "Aylık", "Yıllık"], id: \.self) { Text($0) } }
                Stepper("Hedef Sayı: \(target)", value: $target)
            }
            .navigationTitle("Yeni Hedef")
            .toolbar { Button("Ekle") { modelContext.insert(AppGoal(title: t, targetCount: target, currentCount: 0, period: p)); dismiss() }.disabled(t.isEmpty) }
        }
    }
}

struct InterviewPrepView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InterviewQuestion.createdAt, order: .reverse) private var qs: [InterviewQuestion]
    @State private var showingAdd = false
    @State private var cat = "Tümü"
    var filteredQs: [InterviewQuestion] { cat == "Tümü" ? qs : qs.filter { $0.category == cat } }
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["Tümü", "Genel", "Teknik", "İK", "Vaka"], id: \.self) { c in
                            Button { cat = c } label: { Text(c).font(.caption).fontWeight(.bold).padding(.horizontal, 12).padding(.vertical, 6).background(cat == c ? Color.accentColor : Color.accentColor.opacity(0.1)).foregroundColor(cat == c ? .white : .accentColor).cornerRadius(10) }
                        }
                    }
                }
                
                NavigationLink(destination: MockInterviewView(questions: qs)) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Pratik Yap").fontWeight(.bold)
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.trailing)
                .disabled(qs.isEmpty)
            }
            .padding(.vertical, 8)
            List {
                if filteredQs.isEmpty {
                    VStack(spacing: 20) {
                        ContentUnavailableView("Soru Yok", systemImage: "brain.head.profile.fill", description: Text("Henüz bir mülakat sorusu eklemediniz."))
                        Button("Örnek Soruları Yükle") {
                            let common = [
                                ("Bize kendinden bahset.", "Kısa ve öz bir şekilde eğitim, deneyim ve kariyer hedeflerini anlat.", "Genel"),
                                ("En büyük zayıflığın nedir?", "Gerçek bir zayıflığı ve bunu nasıl geliştirdiğini anlat.", "İK"),
                                ("Neden bu şirketi istiyorsun?", "Şirket araştırmanı ve senin değerlerinle nasıl örtüştüğünü vurgula.", "Genel"),
                                ("Zor bir durumu nasıl yönettin?", "STAR metodunu (Situation, Task, Action, Result) kullanarak anlat.", "Vaka")
                            ]
                            for c in common {
                                modelContext.insert(InterviewQuestion(question: c.0, answer: c.1, category: c.2))
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredQs) { q in
                        DisclosureGroup {
                            Text(q.answer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(q.question).font(.headline)
                                Text(q.category)
                                    .font(.caption2).fontWeight(.bold)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(catColor(for: q.category).opacity(0.1))
                                    .foregroundColor(catColor(for: q.category))
                                    .cornerRadius(6)
                            }
                        }
                        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                        .swipeActions { Button(role: .destructive) { modelContext.delete(q) } label: { Label("Sil", systemImage: "trash") } }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $showingAdd) { AddQuestionView() }
    }
    
    private func catColor(for c: String) -> Color {
        switch c {
        case "Teknik": return .blue
        case "İK": return .purple
        case "Vaka": return .orange
        default: return .pink
        }
    }
}

struct MockInterviewView: View {
    let questions: [InterviewQuestion]
    @State private var currentQuestion: InterviewQuestion?
    @State private var showAnswer = false
    @State private var timeElapsed = 0
    @State private var timerActive = true
    @Environment(\.dismiss) private var dismiss
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            // Timer Header
            HStack {
                Text(timeString(timeElapsed))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.accentColor)
                Spacer()
                Button { timerActive.toggle() } label: {
                    Image(systemName: timerActive ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(20)
            
            if let q = currentQuestion {
                VStack(spacing: 20) {
                    CustomBadge(text: q.category, color: .accentColor)
                    
                    Text(q.question)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if showAnswer {
                        ScrollView {
                            Text(q.answer)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .cornerRadius(16)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Spacer()
                        Button("Cevabı Göster") {
                            withAnimation(.spring()) { showAnswer = true }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
            } else {
                ContentUnavailableView("Soru Yok", systemImage: "brain.head.profile.fill")
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: nextQuestion) {
                    HStack {
                        Text("Sonraki Soru")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Mülakat Pratiği")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { nextQuestion() }
        .onReceive(timer) { _ in if timerActive { timeElapsed += 1 } }
    }
    
    private func nextQuestion() {
        hapticFeedback(.medium)
        withAnimation {
            showAnswer = false
            currentQuestion = questions.randomElement()
        }
    }
    
    private func timeString(_ s: Int) -> String {
        let m = s / 60; let sec = s % 60
        return String(format: "%02d:%02d", m, sec)
    }
}

struct AddQuestionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var q = ""; @State private var a = ""; @State private var c = "Genel"
    var body: some View {
        NavigationStack {
            Form { TextField("Soru", text: $q); Picker("Kategori", selection: $c) { ForEach(["Genel", "Teknik", "İK", "Vaka"], id: \.self) { Text($0) } }; Section("Cevap") { TextEditor(text: $a).frame(minHeight: 150) } }
            .navigationTitle("Yeni Soru")
            .toolbar { Button("Ekle") { modelContext.insert(InterviewQuestion(question: q, answer: a, category: c)); dismiss() }.disabled(q.isEmpty) }
        }
    }
}

struct CVManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CVDocument.uploadDate, order: .reverse) private var cvs: [CVDocument]
    @State private var showingImporter = false
    @State private var shareURL: URL?
    var body: some View {
        List {
            if cvs.isEmpty {
                ContentUnavailableView("CV Bulunamadı", systemImage: "doc.badge.plus", description: Text("Başvurularında kullanacağın CV'leri buraya yükle."))
                    .padding(.top, 40)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(cvs) { cv in
                    HStack(spacing: 15) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(Color.teal.opacity(0.1))
                                .frame(width: 45, height: 45)
                            Image(systemName: "doc.text.fill").foregroundColor(.teal)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cv.name).font(.headline).lineLimit(1)
                            Text(cv.uploadDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2).foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            let u = FileManager.default.temporaryDirectory.appendingPathComponent(cv.name)
                            try? cv.fileData.write(to: u)
                            shareURL = u
                            hapticFeedback(.light)
                        } label: {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.teal)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                    .swipeActions {
                        Button(role: .destructive) { modelContext.delete(cv) } label: { Label("Sil", systemImage: "trash") }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("CV'lerim")
        .toolbar { Button { showingImporter = true } label: { Image(systemName: "plus") } }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.pdf]) { result in
            if case .success(let url) = result {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    let data = (try? Data(contentsOf: url)) ?? Data()
                    modelContext.insert(CVDocument(name: url.lastPathComponent, fileData: data))
                }
            }
        }
        .sheet(item: Binding(get: { shareURL.map { IdentifiableURL(url: $0) } }, set: { shareURL = $0?.url })) { idu in ShareSheet(activityItems: [idu.url]) }
    }
}

struct IdentifiableURL: Identifiable { let id = UUID(); let url: URL }

// MARK: - Helper Views

struct ToolSection<Content: View>: View {
    let title: String; let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
            content().background(Color(uiColor: .secondarySystemGroupedBackground)).cornerRadius(20).shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        }
    }
}

struct ToolRow: View {
    let icon: String; let color: Color; let title: String; let description: String
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

struct ToolTemplate: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct EmailTemplatesView: View {
    let templates = [
        ToolTemplate(title: "Tanışma / LinkedIn", content: "Merhaba [İsim] Bey/Hanım,\n\nLinkedIn üzerinden profilinizi inceledim ve [Şirket Adı] bünyesindeki [Pozisyon] rolüyle yakından ilgileniyorum. Deneyimlerimin ekibinize katkı sağlayabileceğine inanıyorum. Bağlantı kurabilirsek çok memnun olurum.\n\nSaygılarımla,\n[Adınız]"),
        ToolTemplate(title: "Mülakat Sonrası Teşekkür", content: "Sayın [İsim],\n\nBugün gerçekleştirdiğimiz [Pozisyon] mülakatı için çok teşekkür ederim. Ekibinizle tanışmak ve [Şirket Adı] vizyonu hakkında daha fazla bilgi edinmek harikaydı. Pozisyona olan ilgim artarak devam ediyor.\n\nGeri dönüşünüzü sabırsızlıkla bekliyorum.\n\nİyi çalışmalar,\n[Adınız]"),
        ToolTemplate(title: "Süreç Takibi (Follow-up)", content: "Merhaba [İsim] Bey/Hanım,\n\n[Tarih] tarihinde gerçekleştirdiğimiz [Pozisyon] mülakatımın süreciyle ilgili bir güncelleme olup olmadığını sormak istemiştim. Hala pozisyonla yakından ilgileniyorum ve sormak istediğiniz ek bir bilgi olursa yanıtlamaktan memnuniyet duyarım.\n\nTeşekkürler,\n[Adınız]"),
        ToolTemplate(title: "Teklif Kabulü", content: "Sayın [İsim],\n\n[Şirket Adı] bünyesindeki [Pozisyon] teklifinizi büyük bir memnuniyetle kabul ediyorum. Ekibin bir parçası olmak için sabırsızlanıyorum. İşe giriş işlemleri için gerekli evrak listesini paylaşabilirseniz sevinirim.\n\nSaygılarımla,\n[Adınız]"),
        ToolTemplate(title: "Geri Bildirim Talebi", content: "Merhaba [İsim] Bey/Hanım,\n\n[Pozisyon] süreciyle ilgili olumsuz geri dönüşünüzü aldım. Vakit ayırdığınız için teşekkürler. Gelecekteki gelişimim için mülakat performansımla ilgili verebileceğiniz herhangi bir tavsiye veya geri bildirim benim için çok değerli olacaktır.\n\nBaşarılar dilerim,\n[Adınız]")
    ]
    
    var body: some View {
        List {
            ForEach(templates) { t in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(t.title).font(.headline).foregroundColor(.accentColor)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = t.content
                            hapticFeedback(.light)
                        } label: {
                            Label("Kopyala", systemImage: "doc.on.doc.fill").font(.caption).fontWeight(.bold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                    }
                    
                    Text(t.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(5)
                        .padding(12)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(12)
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("E-posta Şablonları")
    }
}

struct CoverLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var letters: [CoverLetter]
    @State private var showingAdd = false
    var body: some View {
        let templates = [
            ToolTemplate(title: "Genel Başvuru", content: "Sayın İşe Alım Yöneticisi,\n\n[Pozisyon] rolü için duyduğum heyecanı paylaşmak istiyorum. [Yetenek] ve [Deneyim] konularındaki birikimimle [Şirket Adı] ekibine değer katacağıma inanıyorum..."),
            ToolTemplate(title: "Yeni Mezun / Staj", content: "Merhaba,\n\n[Okul/Bölüm] mezunu olarak, teorik bilgilerimi [Şirket Adı] gibi öncü bir kurumda pratiğe dökmek istiyorum. Öğrenmeye açık ve disiplinli yapımla ekibinize katkı sağlamaya hazırım...")
        ]
        
        List {
            Section("Örnek Şablonlar") {
                ForEach(templates) { t in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(t.title).font(.subheadline).bold()
                            Spacer()
                            Button("Kopyala") { UIPasteboard.general.string = t.content; hapticFeedback(.light) }
                                .font(.caption).buttonStyle(.bordered)
                        }
                        Text(t.content).font(.caption2).foregroundColor(.secondary).lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Mektuplarım") {
                if letters.isEmpty {
                    Text("Henüz mektup eklenmedi").font(.caption).foregroundColor(.secondary)
                } else {
                    ForEach(letters) { l in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(l.title).font(.headline)
                            Text(l.content).font(.caption).foregroundColor(.secondary).lineLimit(3)
                            Button("Kopyala") { UIPasteboard.general.string = l.content; hapticFeedback(.light) }
                                .font(.caption).buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                        .swipeActions { Button(role: .destructive) { modelContext.delete(l) } label: { Label("Sil", systemImage: "trash") } }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Niyet Mektupları")
        .toolbar { Button { showingAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showingAdd) { AddCoverLetterView() }
    }
}

struct AddCoverLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var t = ""; @State private var c = ""
    var body: some View {
        NavigationStack {
            Form { TextField("Başlık", text: $t); TextEditor(text: $c).frame(minHeight: 200) }
            .navigationTitle("Yeni Niyet Mektubu")
            .toolbar { Button("Ekle") { modelContext.insert(CoverLetter(title: t, content: c)); dismiss() }.disabled(t.isEmpty) }
        }
    }
}


#Preview {
    ToolsTabView()
}
