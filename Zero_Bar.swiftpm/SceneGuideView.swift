import SwiftUI

// MARK: - SceneGuideView
// Full-screen step card experience. No animation area —
// the instruction IS the visual. Swipe to navigate.
// Category-colored accents, large typography, smooth transitions.

struct SceneGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showCompletion = false
    @AppStorage("globalAudioEnabled") private var isSpeaking: Bool = true
    @State private var completedSteps: Set<Int> = []
    @State private var emergencyMode = true
    @State private var dragOffset: CGFloat = 0
    
    let namespace: Namespace.ID
    let item: SurvivalItem
    
    private var accent: Color {
        switch item.category {
        case .medical: return TacticalTheme.danger
        case .auto:    return TacticalTheme.accent
        case .urban:   return Color(hex: "5E9EFF")
        case .wild:    return Color(hex: "4ADE80")
        case .tools:   return Color(hex: "F59E0B")
        }
    }
    
    private var stepCount: Int { item.steps.count }
    private var progress: CGFloat { CGFloat(currentStep + 1) / CGFloat(stepCount) }
    
    var body: some View {
        ZStack {
            // Background — subtle gradient based on category
            LinearGradient(
                colors: [accent.opacity(0.08), TacticalTheme.background, TacticalTheme.background],
                startPoint: .top, endPoint: .center
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                progressBar
                Spacer()
                stepCard
                Spacer()
                toolbar
                controls
            }
            
            if showCompletion { completionOverlay }
            ScanLinesOverlay().ignoresSafeArea()
        }
        .gesture(swipeGesture)
        .onAppear { autoSpeak() }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { stopSpeech(); HapticManager.shared.tap(); dismiss() } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold))
                    Text("BACK").font(.system(size: 11, design: .monospaced).weight(.bold))
                }.foregroundStyle(accent)
            }
            
            Spacer()
            
            Text(item.title.uppercased())
                .font(.system(size: 11, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: item.iconName).font(.system(size: 11, weight: .semibold))
                    .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
            }
            .foregroundStyle(accent.opacity(0.5))
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, 10)
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent.opacity(0.08))
                    .frame(height: 3)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent)
                    .frame(width: geo.size.width * progress, height: 3)
                    .animation(.spring(response: 0.4), value: currentStep)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, AdaptiveLayout.hudPadding)
    }
    
    // MARK: - Step Card (the core)
    private var stepCard: some View {
        VStack(spacing: 0) {
            // Step number + icon
            VStack(spacing: 16) {
                // Large category icon (subtle watermark)
                Image(systemName: StepIconMapper.icon(for: item.steps[currentStep]))
                    .font(.system(size: emergencyMode ? 52 : 44, weight: .light))
                    .foregroundStyle(accent.opacity(0.15))
                    .padding(.top, 12)
                
                // Step counter
                Text("STEP \(currentStep + 1) OF \(stepCount)")
                    .font(.system(size: 12, design: .monospaced).weight(.bold))
                    .foregroundStyle(accent)
                    .tracking(2)
            }
            
            Spacer().frame(height: 28)
            
            // Main instruction text
            Text(item.steps[currentStep])
                .font(.system(size: emergencyMode ? 26 : 19, design: .rounded).weight(emergencyMode ? .bold : .medium))
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(emergencyMode ? 8 : 5)
                .padding(.horizontal, AdaptiveLayout.isIPad ? 48 : 28)
                .id(currentStep)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(x: 40)),
                    removal: .opacity.combined(with: .offset(x: -40))))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentStep)
            
            Spacer().frame(height: 20)
            
            // Step dots
            HStack(spacing: 6) {
                ForEach(0..<stepCount, id: \.self) { i in
                    Circle()
                        .fill(i < currentStep ? Color(hex: "4ADE80") :
                              i == currentStep ? accent :
                              TacticalTheme.textSecondary.opacity(0.15))
                        .frame(width: i == currentStep ? 8 : 5, height: i == currentStep ? 8 : 5)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
        }
        .padding(.vertical, AdaptiveLayout.isIPad ? 32 : 24)
        .frame(maxWidth: AdaptiveLayout.detailMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TacticalTheme.cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(accent.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, AdaptiveLayout.horizontalPadding)
        .offset(x: dragOffset)
    }
    
    // MARK: - Toolbar (TTS, font, checkmark)
    private var toolbar: some View {
        HStack(spacing: 28) {
            // TTS
            Button {
                HapticManager.shared.tap()
                if isSpeaking { stopSpeech() }
                else { speakCurrent() }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text(isSpeaking ? "STOP" : "LISTEN")
                        .font(.system(size: 9, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(isSpeaking ? TacticalTheme.danger : TacticalTheme.textSecondary)
            }
            .accessibilityLabel(isSpeaking ? "Stop reading" : "Read aloud")
            
            // Font size
            Button {
                HapticManager.shared.tap()
                withAnimation(.spring(response: 0.3)) { emergencyMode.toggle() }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 18, weight: .medium))
                    Text(emergencyMode ? "NORMAL" : "LARGE")
                        .font(.system(size: 9, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(emergencyMode ? accent : TacticalTheme.textSecondary)
            }
            .accessibilityLabel(emergencyMode ? "Normal text" : "Large text")
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Navigation Controls
    private var controls: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    HapticManager.shared.tap()
                    goTo(currentStep - 1)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold))
                        Text("PREV").font(.system(size: 12, design: .monospaced).weight(.bold))
                    }.foregroundStyle(TacticalTheme.textSecondary)
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(Capsule().fill(TacticalTheme.cardBackground))
                }
            }
            
            Button {
                if currentStep < stepCount - 1 {
                    HapticManager.shared.success()
                    goTo(currentStep + 1)
                } else {
                    HapticManager.shared.success()
                    stopSpeech()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showCompletion = true }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentStep < stepCount - 1 ? "NEXT STEP" : "COMPLETE")
                        .font(.system(size: 13, design: .monospaced).weight(.black))
                    Image(systemName: currentStep < stepCount - 1 ? "chevron.right" : "checkmark")
                        .font(.system(size: 13, weight: .bold))
                }.foregroundStyle(TacticalTheme.background)
                    .padding(.horizontal, 28).padding(.vertical, 14)
                    .background(Capsule().fill(accent)).glow(accent, radius: 6)
            }
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.bottom, AdaptiveLayout.isIPad ? 24 : 16)
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.green).glow(.green, radius: 16)
                
                Text("PROCEDURE COMPLETE")
                    .font(.system(size: 22, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.textPrimary)
                
                Text("\(item.title) guide completed.\nStay safe and prepared.")
                    .font(TacticalTheme.bodyFont)
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button { HapticManager.shared.tap(); dismiss() } label: {
                    Text("RETURN TO BASE")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.background)
                        .padding(.horizontal, 32).padding(.vertical, 14)
                        .background(Capsule().fill(accent)).glow(accent, radius: 8)
                }
            }
        }.transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                dragOffset = value.translation.width * 0.4
            }
            .onEnded { value in
                let threshold: CGFloat = 60
                if value.translation.width < -threshold && currentStep < stepCount - 1 {
                    HapticManager.shared.tap()
                    goTo(currentStep + 1)
                } else if value.translation.width > threshold && currentStep > 0 {
                    HapticManager.shared.tap()
                    goTo(currentStep - 1)
                }
                withAnimation(.spring(response: 0.3)) { dragOffset = 0 }
            }
    }
    
    // MARK: - Helpers
    private func goTo(_ step: Int) {
        stopSpeech()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentStep = step
        }
        autoSpeak()
    }
    
    private func autoSpeak() {
        guard isSpeaking else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SpeechManager.shared.speak("Step \(currentStep + 1). \(item.steps[currentStep])")
        }
    }
    
    private func speakCurrent() {
        let text = "Step \(currentStep + 1). \(item.steps[currentStep])"
        SpeechManager.shared.speak(text)
        isSpeaking = true
    }
    
    private func stopSpeech() {
        SpeechManager.shared.stop()
        isSpeaking = false
    }
}
