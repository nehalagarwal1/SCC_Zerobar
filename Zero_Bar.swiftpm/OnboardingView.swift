import SwiftUI

// MARK: - OnboardingView
// 4-screen welcome experience that explains the app's purpose.
// Shows on first launch only (persisted via @AppStorage).
// Design: full-screen tactical aesthetic with animated transitions.

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateContent = false
    
    private let pages: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("wifi.slash",
         "ZERO SIGNAL.\nZERO PROBLEM.",
         "When there's no cell service, no Wi-Fi, no internet — you still have this. 60+ survival guides that work completely offline.",
         TacticalTheme.accent),
        ("heart.text.clipboard.fill",
         "LIFE-SAVING\nKNOWLEDGE",
         "From CPR to car breakdowns, bear encounters to building fires. Step-by-step visual instructions sourced from Red Cross, FEMA, and wilderness survival experts.",
         TacticalTheme.danger),
        ("eye.fill",
         "SEE THE ACTION.\nNO READING NEEDED.",
         "Every guide has animated visual scenes — hands pressing, tools moving, objects in motion. Understand what to do just by watching, even under stress.",
         Color(hex: "5AC8FA")),
        ("bolt.shield.fill",
         "YOUR POCKET\nSURVIVAL KIT",
         "Pin your critical guides for instant access. Test your knowledge with quizzes. Be ready before the emergency, not after.",
         Color(hex: "4ADE80")),
        ("exclamationmark.shield.fill",
         "IMPORTANT\nDISCLAIMER",
         AppConstants.disclaimer,
         Color(hex: "FF9500"))
    ]
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Bottom controls
                bottomBar
                    .padding(.bottom, 40)
            }
            
            ScanLinesOverlay().ignoresSafeArea()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Page Content
    private func onboardingPage(index: Int) -> some View {
        let page = pages[index]
        return VStack(spacing: 28) {
            Spacer()
            
            // Animated icon with glow
            ZStack {
                // Pulse rings
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(page.color.opacity(0.15), lineWidth: 1.5)
                        .frame(
                            width: animateContent ? CGFloat(130 + i * 40) : CGFloat(80 + i * 20),
                            height: animateContent ? CGFloat(130 + i * 40) : CGFloat(80 + i * 20)
                        )
                        .opacity(animateContent ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.4),
                            value: animateContent
                        )
                }
                
                // Icon background circle
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 100, height: 100)
                
                // Main icon
                Image(systemName: page.icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(page.color)
                    .glow(page.color, radius: 14)
            }
            .frame(height: 160)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Subtitle
            Text(page.subtitle)
                .font(.system(size: 16, design: .rounded).weight(.medium))
                .foregroundStyle(TacticalTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 24) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? pages[currentPage].color : TacticalTheme.textSecondary.opacity(0.3))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            
            // Action button
            Button {
                HapticManager.shared.tap()
                if currentPage < pages.count - 1 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    // Complete onboarding
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        hasCompletedOnboarding = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(currentPage < pages.count - 1 ? "CONTINUE" : "GET STARTED")
                        .font(.system(size: 16, design: .monospaced).weight(.black))
                    Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(TacticalTheme.background)
                .frame(maxWidth: 280)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(pages[currentPage].color)
                )
                .glow(pages[currentPage].color, radius: 8)
            }
            
            // Skip button (except on last page)
            if currentPage < pages.count - 1 {
                Button {
                    HapticManager.shared.tap()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text("SKIP")
                        .font(.system(size: 12, design: .monospaced).weight(.bold))
                        .foregroundStyle(TacticalTheme.textSecondary)
                }
            } else {
                // Placeholder to maintain layout height
                Text(" ")
                    .font(.system(size: 12))
                    .opacity(0)
            }
        }
        .padding(.horizontal, 24)
    }
}
