import SwiftUI

struct JobBoardView: View {
    @StateObject private var viewModel = JobBoardViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Staj İlanları / Kariyer Tavsiyeleri")
                            .font(.title2)
                            .bold()

                        Text("Bu ekran public bir servisten güncel iş/staj ilanlarını çeker, listeler ve yeni ilan algılandığında local bildirim planlar.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("Örn: internship, ios, android", text: $viewModel.searchText)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await viewModel.loadJobs() }
                                }

                            Button {
                                Task { await viewModel.loadJobs() }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(viewModel.isLoading)
                        }

                        HStack {
                            Label("Son güncelleme: \(viewModel.lastUpdateText)", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Section("Kariyer Tavsiyeleri") {
                    CareerTipRow(
                        icon: "doc.text.magnifyingglass",
                        title: "CV’ni ilana göre düzenle",
                        description: "Her ilana aynı CV ile başvurmak yerine, ilandaki anahtar teknolojilere göre kısa uyarlamalar yap."
                    )

                    CareerTipRow(
                        icon: "bell.badge.fill",
                        title: "Deadline bildirimi kullan",
                        description: "Başvuru son tarihi ve mülakat tarihi yaklaşınca bildirim almak başvuru disiplinini ciddi artırır."
                    )

                    CareerTipRow(
                        icon: "map.fill",
                        title: "Şirket lokasyonunu kontrol et",
                        description: "Hibrit/ofis stajlarda ulaşım süresi, karar vermede önemli bir kriterdir."
                    )
                }

                Section("API’den Gelen İlanlar") {
                    if viewModel.jobs.isEmpty && !viewModel.isLoading {
                        ContentUnavailableView(
                            "Henüz ilan yok",
                            systemImage: "briefcase",
                            description: Text("İlanları çekmek için yenile butonuna bas.")
                        )
                    } else {
                        ForEach(viewModel.jobs) { job in
                            JobRow(job: job)
                        }
                    }
                }

                Section("Demo") {
                    Button {
                        viewModel.sendDemoNotification()
                    } label: {
                        Label("Test bildirimi gönder", systemImage: "bell.fill")
                    }

                    Button(role: .destructive) {
                        viewModel.resetSeenJobsForDemo()
                    } label: {
                        Label("İlan bildirim geçmişini sıfırla", systemImage: "arrow.counterclockwise")
                    }
                }

                Section {
                    Text("İlan verileri Remotive public API üzerinden alınır. Başvuru bağlantılarında kaynak olarak Remotive gösterilir.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("İlanlar")
            .task {
                if viewModel.jobs.isEmpty {
                    await viewModel.loadJobs()
                }
            }
        }
    }
}

private struct JobRow: View {
    let job: RemoteJob

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.title)
                .font(.headline)

            Text(job.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Label(job.locationText, systemImage: "location")
                if let jobType = job.jobType, !jobType.isEmpty {
                    Label(jobType, systemImage: "clock")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let category = job.category, !category.isEmpty {
                Text(category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }

            if let salary = job.salary, !salary.isEmpty {
                Text("Maaş: \(salary)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !job.cleanedDescription.isEmpty {
                Text(job.cleanedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                Text("Kaynak: \(job.sourceText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                if let url = job.applyURL {
                    Link(destination: url) {
                        Label("İlana Git", systemImage: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

private struct CareerTipRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    JobBoardView()
}
