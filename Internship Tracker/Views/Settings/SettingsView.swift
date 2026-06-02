import SwiftUI

struct SettingsView: View {
    @AppStorage("accentColorName") private var accentColorName = "indigo"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    let colors: [(name: String, color: Color, label: String)] = [
        ("indigo", .indigo, "İndigo"),
        ("blue", .blue, "Okyanus"),
        ("purple", .purple, "Mistik"),
        ("teal", .teal, "Turkuaz"),
        ("green", .green, "Doğa"),
        ("orange", .orange, "Enerji"),
        ("pink", .pink, "Modern")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header Placeholder
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.accentColor.gradient.opacity(0.15)).frame(width: 100, height: 100)
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 60)).foregroundColor(.accentColor)
                    }
                    Text("Staj Takipçim").font(.title2).fontWeight(.bold)
                    Text("Kariyer Yönetim Paneli").font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Theme Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Uygulama Teması", systemImage: "paintpalette.fill").font(.headline).fontWeight(.bold)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                        ForEach(colors, id: \.name) { item in
                            Button {
                                hapticFeedback(.light)
                                withAnimation(.spring) { accentColorName = item.name }
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle().fill(item.color).frame(width: 44, height: 44)
                                        if accentColorName == item.name {
                                            Image(systemName: "checkmark").foregroundColor(.white).font(.system(size: 14, weight: .bold))
                                        }
                                    }
                                    Text(item.label).font(.caption).fontWeight(.medium).foregroundColor(accentColorName == item.name ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(24)
                }
                .padding(.horizontal)

                // App Info
                VStack(alignment: .leading, spacing: 16) {
                    Label("Uygulama Bilgileri", systemImage: "info.circle.fill").font(.headline).fontWeight(.bold)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "star.fill", color: .yellow, title: "Versiyon", value: "2.5.0 Premium")
                        Divider().padding(.leading, 50)
                        SettingsRow(icon: "shield.fill", color: .blue, title: "Veri Koruma", value: "SwiftData Gömülü")
                        Divider().padding(.leading, 50)
                        Button { 
                            hapticFeedback(.medium)
                            withAnimation { hasSeenOnboarding = false } 
                        } label: {
                            SettingsRow(icon: "arrow.counterclockwise", color: .orange, title: "Karşılama Ekranı", value: "Sıfırla")
                        }.buttonStyle(.plain)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(24)
                }
                .padding(.horizontal)

                // Footer
                VStack(spacing: 8) {
                    Text("Made with ❤️ for Careers").font(.caption).foregroundColor(.secondary)
                    Text("© 2026 Internship Tracker").font(.caption2).foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.vertical, 40)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Ayarlar")
        .fontDesign(.rounded)
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct SettingsRow: View {
    let icon: String; let color: Color; let title: String; let value: String
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.12)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.subheadline).foregroundColor(color)
            }
            Text(title).font(.subheadline).fontWeight(.medium)
            Spacer()
            Text(value).font(.subheadline).foregroundColor(.secondary)
            if value == "Sıfırla" { Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary) }
        }
        .padding(16)
    }
}


#Preview {
    SettingsView()
}
