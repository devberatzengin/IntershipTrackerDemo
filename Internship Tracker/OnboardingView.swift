import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @Namespace private var animation

    private let pages: [(icon: String, color: Color, title: String, description: String, secondaryColor: Color)] = [
        (
            "briefcase.fill",
            .indigo,
            "Kariyerini Yönet",
            "Tüm staj ve iş başvurularını tek bir profesyonel merkezden kontrol et.",
            .blue
        ),
        (
            "chart.bar.fill",
            .purple,
            "Verilerle İlerle",
            "Başvuru istatistiklerini ve mülakat performansını detaylı grafiklerle izle.",
            .pink
        ),
        (
            "hand.thumbsup.fill",
            .teal,
            "Hedefe Ulaş",
            "Niyet mektupları, referanslar ve mülakat hazırlığı ile fark yarat.",
            .green
        )
    ]

    var body: some View {
        ZStack {
            // Premium background
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            GeometryReader { geo in
                Circle()
                    .fill(pages[currentPage].color.opacity(0.1))
                    .frame(width: geo.size.width * 1.5, height: geo.size.width * 1.5)
                    .offset(x: -geo.size.width * 0.5, y: -geo.size.height * 0.4)
                    .blur(radius: 60)
                
                Circle()
                    .fill(pages[currentPage].secondaryColor.opacity(0.1))
                    .frame(width: geo.size.width, height: geo.size.width)
                    .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.5)
                    .blur(radius: 60)
            }
            .animation(.easeInOut(duration: 1.0), value: currentPage)

            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(pages[currentPage].color)
                        Text("Internship Tracker")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .tracking(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Geç") {
                            hapticFeedback(.medium)
                            withAnimation { hasSeenOnboarding = true }
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageContent(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom UI
                VStack(spacing: 30) {
                    // Custom Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == currentPage ? pages[currentPage].color : Color.secondary.opacity(0.2))
                                .frame(width: index == currentPage ? 32 : 8, height: 8)
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)

                    Button(action: {
                        hapticFeedback(.light)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                hapticFeedback(.success)
                                hasSeenOnboarding = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Sonraki" : "Haydi Başlayalım")
                                .font(.headline)
                            if currentPage < pages.count - 1 {
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].color, pages[currentPage].secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: pages[currentPage].color.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
        .fontDesign(.rounded)
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

struct OnboardingPageContent: View {
    let page: (icon: String, color: Color, title: String, description: String, secondaryColor: Color)
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 40) {
            // Visual Container
            ZStack {
                // Background shapes
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 240, height: 240)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Circle()
                    .stroke(page.color.opacity(0.2), lineWidth: 1)
                    .frame(width: 280, height: 280)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                // Main Icon with glass effect
                ZStack {
                    RoundedRectangle(cornerRadius: 45)
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 160)
                        .shadow(color: page.color.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 70, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.color, page.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: isAnimating)
                }
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
            }
            .frame(height: 320)
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
