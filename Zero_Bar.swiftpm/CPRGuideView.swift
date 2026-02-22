import SwiftUI

// MARK: - CPRGuideView
// Interactive CPR guide with a pulsing metronome rhythm indicator.
// The compression rate visual + haptic feedback trains muscle memory
// for 100–120 BPM chest compressions — the AHA-recommended rate.

struct CPRGuideView: View {
    
    @State private var currentStep = 0
    @State private var isPulsing = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var showMetronome = false
    @Environment(\.dismiss) private var dismiss
    
    let namespace: Namespace.ID
    let item: SurvivalItem
    
    // CPR step data with icons and detailed instructions
    private let steps: [(title: String, detail: String, icon: String)] = [
        ("CHECK SCENE",
         "Ensure the area is safe. Tap the person's shoulders and shout 'Are you okay?' Call emergency services immediately.",
         "eye.fill"),
        ("HAND PLACEMENT",
         "Place the heel of one hand on the center of the chest (lower half of sternum). Place your other hand on top, fingers interlocked.",
         "hand.raised.fingers.spread.fill"),
        ("COMPRESSIONS",
         "Push hard and fast — at least 2 inches deep. Maintain a rate of 100–120 compressions per minute. Allow full chest recoil.",
         "heart.fill"),
        ("RESCUE BREATHS",
         "After 30 compressions, tilt the head back, lift the chin. Give 2 rescue breaths (1 second each). Watch for chest rise.",
         "lungs.fill"),
        ("CONTINUE",
         "Repeat cycles of 30 compressions + 2 breaths. Continue until an AED arrives, EMS takes over, or the person starts breathing.",
         "arrow.clockwise.heart.fill")
    ]
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                topBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AdaptiveLayout.isIPad ? 32 : 24) {
                        // Heart rhythm visualization
                        heartRhythmView
                            .padding(.top, AdaptiveLayout.isIPad ? 20 : 12)
                        
                        // Step cards
                        ForEach(Array(steps.enumerated()), id: \.0) { index, step in
                            stepCard(index: index, step: step)
                        }
                        
                        // Metronome practice button
                        metronomeButton
                            .padding(.top, 8)
                        
                        Spacer(minLength: 80)
                    }
                    .frame(maxWidth: AdaptiveLayout.detailMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                }
            }
            
            // Metronome overlay
            if showMetronome {
                metronomeOverlay
            }
            
            ScanLinesOverlay()
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                HapticManager.shared.tap()
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                    Text("BACK")
                        .font(.system(size: 12, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(TacticalTheme.accent)
            }
            
            Spacer()
            
            Text("CPR GUIDE")
                .font(.system(size: 14, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.accent)
                .glow(TacticalTheme.accent, radius: 4)
            
            Spacer()
            
            // Priority marker
            HStack(spacing: 4) {
                Circle()
                    .fill(TacticalTheme.danger)
                    .frame(width: 6, height: 6)
                Text("CRITICAL")
                    .font(.system(size: 10, design: .monospaced).weight(.bold))
            }
            .foregroundStyle(TacticalTheme.danger)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(TacticalTheme.danger.opacity(0.15))
            )
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, AdaptiveLayout.isIPad ? 16 : 12)
    }
    
    // MARK: - Heart Rhythm Visualization
    // Pulsating heart that beats at ~110 BPM (the target CPR rate midpoint).
    private var heartRhythmView: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer pulse ring
                Circle()
                    .fill(TacticalTheme.danger.opacity(0.1))
                    .frame(width: AdaptiveLayout.isIPad ? 200 : 140, height: AdaptiveLayout.isIPad ? 200 : 140)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)
                
                // Middle pulse ring
                Circle()
                    .fill(TacticalTheme.danger.opacity(0.15))
                    .frame(width: AdaptiveLayout.isIPad ? 150 : 100, height: AdaptiveLayout.isIPad ? 150 : 100)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .opacity(isPulsing ? 0.2 : 0.6)
                
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: AdaptiveLayout.isIPad ? 72 : 52))
                    .foregroundStyle(TacticalTheme.danger)
                    .scaleEffect(isPulsing ? 1.15 : 0.95)
                    .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
            }
            .animation(
                .easeInOut(duration: 0.545) // ~110 BPM
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
            
            VStack(spacing: 4) {
                Text("TARGET RATE")
                    .font(.system(size: 10, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
                
                HStack(spacing: 4) {
                    Text("100–120")
                        .font(.system(size: 28, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.danger)
                    
                    Text("BPM")
                        .font(.system(size: 14, design: .monospaced).weight(.bold))
                        .foregroundStyle(TacticalTheme.textSecondary)
                        .offset(y: 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TacticalTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(TacticalTheme.danger.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Step Card
    private func stepCard(index: Int, step: (title: String, detail: String, icon: String)) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Step number + icon
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            index == currentStep
                                ? TacticalTheme.accent
                                : TacticalTheme.cardBackground
                        )
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: step.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            index == currentStep
                                ? TacticalTheme.background
                                : TacticalTheme.textSecondary
                        )
                }
                
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(
                            index < currentStep
                                ? TacticalTheme.accent.opacity(0.5)
                                : TacticalTheme.textSecondary.opacity(0.15)
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.system(size: 14, design: .monospaced).weight(.black))
                    .foregroundStyle(
                        index == currentStep
                            ? TacticalTheme.accent
                            : TacticalTheme.textSecondary
                    )
                
                Text(step.detail)
                    .font(.system(size: 14, design: .rounded).weight(.medium))
                    .foregroundStyle(
                        index == currentStep
                            ? TacticalTheme.textPrimary
                            : TacticalTheme.textSecondary.opacity(0.7)
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
            .onTapGesture {
                HapticManager.shared.tap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    currentStep = index
                }
            }
        }
    }
    
    // MARK: - Metronome Button
    private var metronomeButton: some View {
        Button {
            HapticManager.shared.success()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                showMetronome = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "metronome.fill")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRACTICE RHYTHM")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                    Text("Haptic-guided compression timing")
                        .font(.system(size: 11, design: .monospaced))
                        .opacity(0.7)
                }
            }
            .foregroundStyle(TacticalTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TacticalTheme.accent)
            )
            .glow(TacticalTheme.accent, radius: 6)
        }
    }
    
    // MARK: - Metronome Overlay
    // Full-screen rhythm trainer with haptic pulses at 110 BPM.
    private var metronomeOverlay: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            
            MetronomeView {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMetronome = false
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Metronome View
// Standalone metronome component with visual + haptic beats.
struct MetronomeView: View {
    let onDismiss: () -> Void
    
    @State private var isActive = false
    @State private var beat = false
    @State private var compressionCount = 0
    @State private var timerTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Large push indicator
            ZStack {
                Circle()
                    .fill(TacticalTheme.danger.opacity(beat ? 0.4 : 0.1))
                    .frame(width: AdaptiveLayout.isIPad ? 280 : 200, height: AdaptiveLayout.isIPad ? 280 : 200)
                    .animation(.easeOut(duration: 0.15), value: beat)
                
                Circle()
                    .stroke(TacticalTheme.danger, lineWidth: beat ? 4 : 2)
                    .frame(width: AdaptiveLayout.isIPad ? 280 : 200, height: AdaptiveLayout.isIPad ? 280 : 200)
                
                VStack(spacing: 8) {
                    Text("PUSH")
                        .font(.system(size: AdaptiveLayout.isIPad ? 48 : 36, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.danger)
                    
                    Text("\(compressionCount)")
                        .font(.system(size: AdaptiveLayout.isIPad ? 64 : 48, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.textPrimary)
                }
            }
            .scaleEffect(beat ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.15), value: beat)
            
            // Rate label
            Text("110 BPM — Staying Alive Tempo")
                .font(.system(size: 13, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
            
            Spacer()
            
            // Controls
            HStack(spacing: 20) {
                Button {
                    HapticManager.shared.tap()
                    if isActive {
                        stopMetronome()
                    } else {
                        startMetronome()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(isActive ? "PAUSE" : "START")
                            .font(.system(size: 14, design: .monospaced).weight(.black))
                    }
                    .foregroundStyle(TacticalTheme.background)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(TacticalTheme.danger)
                    )
                }
                
                Button {
                    HapticManager.shared.tap()
                    stopMetronome()
                    onDismiss()
                } label: {
                    Text("CLOSE")
                        .font(.system(size: 14, design: .monospaced).weight(.bold))
                        .foregroundStyle(TacticalTheme.textSecondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(TacticalTheme.cardBackground)
                        )
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // ~110 BPM = 545ms interval
    private func startMetronome() {
        isActive = true
        compressionCount = 0
        timerTask = Task { @MainActor in
            while !Task.isCancelled && isActive {
                beat = true
                compressionCount += 1
                HapticManager.shared.heavy()
                
                try? await Task.sleep(nanoseconds: 150_000_000) // beat visual duration
                beat = false
                
                try? await Task.sleep(nanoseconds: 395_000_000) // remaining interval
            }
        }
    }
    
    private func stopMetronome() {
        isActive = false
        timerTask?.cancel()
        timerTask = nil
    }
}
