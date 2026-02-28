import SwiftUI

// MARK: - TireChangeARView
// Clean card-based tire change guide.
// Auto-reads each step aloud. Large text by default.

struct TireChangeARView: View {
    @State private var currentStep = 0
    @State private var showCompletion = false
    @AppStorage("globalAudioEnabled") private var isSpeaking: Bool = true
    @State private var completedSteps: Set<Int> = []
    @State private var dragOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    let namespace: Namespace.ID
    let item: SurvivalItem
    
    private let accent = TacticalTheme.accent
    
    private let steps: [(title: String, instruction: String, icon: String)] = [
        ("STEP 1", "Engage parking brake and place wheel chocks behind tires.",
         "exclamationmark.triangle.fill"),
        ("STEP 2", "Locate the jack point on the vehicle frame — look for the notch near the flat tire.",
         "scope"),
        ("STEP 3", "Position the jack and raise the vehicle until the tire clears the ground by 1 inch.",
         "arrow.up.circle.fill"),
        ("STEP 4", "Loosen lug nuts counter-clockwise using a star pattern. Remove flat tire.",
         "arrow.counterclockwise.circle.fill"),
        ("STEP 5", "Mount the spare tire. Hand-tighten lug nuts in a star pattern.",
         "checkmark.circle.fill"),
        ("STEP 6", "Lower vehicle and torque all lug nuts to manufacturer spec.",
         "wrench.and.screwdriver.fill")
    ]
    
    private var stepCount: Int { steps.count }
    private var progress: CGFloat { CGFloat(currentStep + 1) / CGFloat(stepCount) }
    
    var body: some View {
        ZStack {
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
            
            Text("CHANGE TIRE")
                .font(.system(size: 11, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
            
            Spacer()
            
            Image(systemName: "car.fill").font(.system(size: 11, weight: .semibold))
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
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
    
    // MARK: - Step Card
    private var stepCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(accent.opacity(0.15))
                    .padding(.top, 12)
                
                Text("STEP \(currentStep + 1) OF \(stepCount)")
                    .font(.system(size: 12, design: .monospaced).weight(.bold))
                    .foregroundStyle(accent)
                    .tracking(2)
            }
            
            Spacer().frame(height: 28)
            
            Text(steps[currentStep].instruction)
                .font(.system(size: 22, design: .rounded).weight(.semibold))
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)
                .padding(.horizontal, AdaptiveLayout.isIPad ? 48 : 28)
                .id(currentStep)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(x: 40)),
                    removal: .opacity.combined(with: .offset(x: -40))))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentStep)
            
            Spacer().frame(height: 20)
            
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
    
    // MARK: - Toolbar
    private var toolbar: some View {
        HStack(spacing: 28) {
            Button {
                HapticManager.shared.tap()
                if isSpeaking { stopSpeech() }
                else { speakCurrent() }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text(isSpeaking ? "STOP" : "REPLAY")
                        .font(.system(size: 9, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(isSpeaking ? TacticalTheme.danger : TacticalTheme.textSecondary)
            }
            
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Controls
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
    
    // MARK: - Completion
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 72))
                    .foregroundStyle(Color.green).glow(.green, radius: 16)
                Text("PROCEDURE COMPLETE")
                    .font(.system(size: 22, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.textPrimary)
                Text("Tire successfully changed.\nDrive to nearest service center to replace spare.")
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
    
    // MARK: - Swipe
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in dragOffset = value.translation.width * 0.4 }
            .onEnded { value in
                let t: CGFloat = 60
                if value.translation.width < -t && currentStep < stepCount - 1 {
                    HapticManager.shared.tap(); goTo(currentStep + 1)
                } else if value.translation.width > t && currentStep > 0 {
                    HapticManager.shared.tap(); goTo(currentStep - 1)
                }
                withAnimation(.spring(response: 0.3)) { dragOffset = 0 }
            }
    }
    
    // MARK: - Helpers
    private func goTo(_ step: Int) {
        stopSpeech()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { currentStep = step }
        autoSpeak()
    }
    
    private func autoSpeak() {
        guard isSpeaking else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SpeechManager.shared.speak("Step \(currentStep + 1). \(steps[currentStep].instruction)")
        }
    }
    
    private func speakCurrent() {
        let text = "Step \(currentStep + 1). \(steps[currentStep].instruction)"
        SpeechManager.shared.speak(text)
        isSpeaking = true
    }
    
    private func stopSpeech() {
        SpeechManager.shared.stop()
        isSpeaking = false
    }
}

// MARK: - Custom Shapes (kept for potential future use)

struct CarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.05, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.65))
        path.addQuadCurve(to: CGPoint(x: w * 0.08, y: h * 0.55), control: CGPoint(x: w * 0.02, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.5))
        path.addQuadCurve(to: CGPoint(x: w * 0.98, y: h * 0.65), control: CGPoint(x: w * 0.98, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.75))
        return path
    }
}

struct ChockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.7, y: 0))
        path.closeSubpath()
        return path
    }
}

struct VNotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct JackShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w / 2, y: 0))
        path.addLine(to: CGPoint(x: w, y: h / 2))
        path.addLine(to: CGPoint(x: w / 2, y: h))
        path.addLine(to: CGPoint(x: 0, y: h / 2))
        path.closeSubpath()
        return path
    }
}

struct StarPatternShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        var pts: [CGPoint] = []
        for i in 0..<5 {
            let a = (Double(i) * 72.0 - 90.0) * Double.pi / 180.0
            pts.append(CGPoint(x: cx + CGFloat(cos(a)) * r, y: cy + CGFloat(sin(a)) * r))
        }
        path.move(to: pts[0])
        path.addLine(to: pts[2])
        path.addLine(to: pts[4])
        path.addLine(to: pts[1])
        path.addLine(to: pts[3])
        path.addLine(to: pts[0])
        return path
    }
}
