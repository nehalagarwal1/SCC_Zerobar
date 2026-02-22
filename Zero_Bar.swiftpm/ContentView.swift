import SwiftUI

// MARK: - ContentView
// Root navigation controller using NavigationStack.
// Manages the matchedGeometryEffect namespace so hero transitions
// flow seamlessly from grid cards → detail views.
//
// Architecture decision: Using NavigationStack (iOS 16+) instead of
// NavigationView for type-safe, value-based navigation. This avoids
// the deprecated NavigationView split behavior on iPad.

struct ContentView: View {
    
    // Shared namespace for matchedGeometryEffect hero transitions.
    // Passed down to SurvivalGridView and detail views so the same
    // SF Symbol + card background can morph smoothly across screens.
    @Namespace private var heroNamespace
    
    // Navigation path for programmatic routing
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            SurvivalGridView(namespace: heroNamespace)
                .navigationBarHidden(true)
                .navigationDestination(for: SurvivalItem.self) { item in
                    destinationView(for: item)
                }
        }
        // Force dark mode across the entire app — OLED optimized
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Routing
    // Routes unlocked items to their specific detail views.
    @ViewBuilder
    private func destinationView(for item: SurvivalItem) -> some View {
        switch item.id {
        case 1:
            CPRGuideView(namespace: heroNamespace, item: item)
                .navigationBarHidden(true)
        case 11:
            TireChangeARView(namespace: heroNamespace, item: item)
                .navigationBarHidden(true)
        default:
            // Fallback for any future unlocked modules
            GenericGuideView(namespace: heroNamespace, item: item)
                .navigationBarHidden(true)
        }
    }
}

// MARK: - Generic Guide View
// Interactive step-by-step guide matching TireChangeARView's visual quality.
// Features: animated icon visualization, step navigation, grid background,
// instruction HUD card with progress dots, and completion overlay.
struct GenericGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var animateIcon = false
    @State private var showCompletion = false
    
    let namespace: Namespace.ID
    let item: SurvivalItem
    
    /// Category-aware accent color for visual variety across modules
    private var accentColor: Color {
        switch item.category {
        case .medical: return TacticalTheme.danger
        case .auto:    return TacticalTheme.accent
        case .urban:   return Color(hex: "5E9EFF")  // cool blue
        case .wild:    return Color(hex: "4ADE80")   // forest green
        case .tools:   return Color(hex: "F59E0B")   // amber
        }
    }
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Top Bar ─────────────────────────
                genericTopBar
                
                // ── Schematic Visualization ─────────
                genericSchematicView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // ── Instruction HUD Card ────────────
                genericInstructionCard
                
                // ── Navigation Controls ─────────────
                genericBottomControls
            }
            
            // Completion overlay
            if showCompletion {
                genericCompletionOverlay
            }
            
            ScanLinesOverlay()
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Top Bar
    private var genericTopBar: some View {
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
                .foregroundStyle(accentColor)
            }
            
            Spacer()
            
            // Step counter
            Text("\(currentStep + 1) / \(item.steps.count)")
                .font(TacticalTheme.caption)
                .foregroundStyle(TacticalTheme.textSecondary)
            
            Spacer()
            
            // Category badge
            HStack(spacing: 4) {
                Image(systemName: item.category.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(item.category.rawValue.uppercased())
                    .font(.system(size: 10, design: .monospaced).weight(.bold))
            }
            .foregroundStyle(accentColor.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(accentColor.opacity(0.1))
            )
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, AdaptiveLayout.isIPad ? 16 : 12)
    }
    
    // MARK: - Animation Mode
    // Keyword-driven animation selection — each mode creates a visually
    // distinct animation that depicts the instruction content, matching
    // TireChangeARView's per-step annotation approach.
    private enum AnimationMode {
        case warning      // ⚠️ pulsing opacity — danger, do not, avoid
        case pointDown    // ⬇️ bouncing arrow — locate, find, look, position
        case liftUp       // ⬆️ rising motion — raise, lift, elevate, remove
        case rotate       // 🔄 spinning — loosen, tighten, turn, unscrew, clockwise
        case pressDown    // 👇 push/compress — push, press, compress, apply pressure
        case slideIn      // ➡️ slide into place — place, mount, attach, cover, wrap
        case heartbeat    // 💓 rhythmic pulse — heart, CPR, compressions, breathe
        case scan         // 👁 sweep/search — check, inspect, monitor, recognize
        case wave         // 🌊 bobbing — water, swim, float, river, flood
        case flicker      // 🔥 flutter — fire, flame, heat, burn, torch
        case done         // ✅ completion glow — continue, repeat, complete, return
    }
    
    /// Determines animation mode from step text keywords
    private var currentAnimationMode: AnimationMode {
        guard currentStep < item.steps.count else { return .scan }
        let s = item.steps[currentStep].lowercased()
        
        // Order matters: most specific first
        if s.contains("heart") || s.contains("cpr") || s.contains("compression") || s.contains("bpm")
            { return .heartbeat }
        if s.contains("fire") || s.contains("flame") || s.contains("ignite") || s.contains("torch") || s.contains("burn")
            { return .flicker }
        if s.contains("water") || s.contains("swim") || s.contains("float") || s.contains("river") || s.contains("flood") || s.contains("rain")
            { return .wave }
        if s.contains("do not") || s.contains("don't") || s.contains("never") || s.contains("danger") || s.contains("warning") || s.contains("caution") || s.contains("avoid") || s.contains("emergency") || s.contains("911") || s.contains("immediately")
            { return .warning }
        if s.contains("loosen") || s.contains("tighten") || s.contains("turn") || s.contains("unscrew") || s.contains("screw") || s.contains("rotate") || s.contains("clockwise") || s.contains("counterclockwise") || s.contains("twist")
            { return .rotate }
        if s.contains("raise") || s.contains("lift") || s.contains("elevate") || s.contains("remove") || s.contains("pull") || s.contains("up ")
            { return .liftUp }
        if s.contains("push") || s.contains("press") || s.contains("compress") || s.contains("apply pressure") || s.contains("squeeze") || s.contains("pump")
            { return .pressDown }
        if s.contains("place") || s.contains("mount") || s.contains("attach") || s.contains("cover") || s.contains("wrap") || s.contains("put") || s.contains("lay ") || s.contains("insert") || s.contains("connect") || s.contains("secure")
            { return .slideIn }
        if s.contains("locate") || s.contains("find") || s.contains("look") || s.contains("position") || s.contains("point") || s.contains("identify") || s.contains("spot")
            { return .pointDown }
        if s.contains("continue") || s.contains("repeat") || s.contains("complete") || s.contains("return") || s.contains("drive") || s.contains("after")
            { return .done }
        if s.contains("check") || s.contains("inspect") || s.contains("monitor") || s.contains("recognize") || s.contains("ensure") || s.contains("watch") || s.contains("observe") || s.contains("assess")
            { return .scan }
        
        return .scan
    }
    
    /// Current step's contextual icon from StepIconMapper
    private var stepIcon: String {
        guard currentStep < item.steps.count else { return item.iconName }
        return StepIconMapper.icon(for: item.steps[currentStep])
    }
    
    /// Keyword for the action label shown beneath the icon
    private var actionLabel: String {
        switch currentAnimationMode {
        case .warning:   return "⚠ CAUTION"
        case .pointDown: return "▼ LOCATE"
        case .liftUp:    return "▲ LIFT"
        case .rotate:    return "↻ TURN"
        case .pressDown: return "⇣ PRESS"
        case .slideIn:   return "→ PLACE"
        case .heartbeat: return "♥ RHYTHM"
        case .scan:      return "◎ CHECK"
        case .wave:      return "≋ FLOW"
        case .flicker:   return "✦ HEAT"
        case .done:      return "✓ GO"
        }
    }
    
    // MARK: - Schematic Visualization
    // Rich per-step animated visualization driven by AnimationMode.
    private var genericSchematicView: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let centerX = w / 2
            let centerY = h / 2
            let iconSize: CGFloat = AdaptiveLayout.isIPad ? 56 : 42
            
            ZStack {
                // Grid background for technical feel
                Canvas { context, size in
                    let gridSpacing: CGFloat = AdaptiveLayout.isIPad ? 50 : 30
                    let lineColor = Color.white.opacity(0.04)
                    
                    var x: CGFloat = 0
                    while x <= size.width {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                        x += gridSpacing
                    }
                    
                    var y: CGFloat = 0
                    while y <= size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                        y += gridSpacing
                    }
                }
                
                // Rotating dashed border ring
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(accentColor.opacity(0.2))
                    .frame(
                        width: AdaptiveLayout.isIPad ? 200 : 145,
                        height: AdaptiveLayout.isIPad ? 200 : 145
                    )
                    .rotationEffect(.degrees(animateIcon ? 360 : 0))
                    .position(x: centerX, y: centerY)
                    .animation(
                        .linear(duration: 12).repeatForever(autoreverses: false),
                        value: animateIcon
                    )
                
                // Inner glow circle — color shifts with mode
                Circle()
                    .fill(accentColor.opacity(currentAnimationMode == .warning ? 0.12 : 0.06))
                    .frame(
                        width: AdaptiveLayout.isIPad ? 150 : 110,
                        height: AdaptiveLayout.isIPad ? 150 : 110
                    )
                    .position(x: centerX, y: centerY)
                
                // ── Mode-specific animation ─────────────────
                stepAnimation(centerX: centerX, centerY: centerY, iconSize: iconSize)
                
                // Item title label (above)
                Text(item.title.uppercased())
                    .font(.system(size: AdaptiveLayout.isIPad ? 13 : 11, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .position(x: centerX, y: centerY - (AdaptiveLayout.isIPad ? 100 : 75))
                
                // Action label (below)
                Text(actionLabel)
                    .font(.system(size: AdaptiveLayout.isIPad ? 12 : 10, design: .monospaced).weight(.black))
                    .foregroundStyle(accentColor)
                    .position(x: centerX, y: centerY + (AdaptiveLayout.isIPad ? 100 : 75))
                    .glow(accentColor, radius: 4)
                
                // Step counter
                Text("STEP \(currentStep + 1)")
                    .font(.system(size: 11, design: .monospaced).weight(.black))
                    .foregroundStyle(accentColor.opacity(0.6))
                    .position(x: centerX, y: centerY + (AdaptiveLayout.isIPad ? 118 : 90))
            }
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
    }
    
    // MARK: - Per-Step Animation
    // Each AnimationMode gets a unique visual — mirroring how TireChangeARView
    // uses different annotations (bouncing arrows, spinning icons, sliding objects).
    @ViewBuilder
    private func stepAnimation(centerX: CGFloat, centerY: CGFloat, iconSize: CGFloat) -> some View {
        let mode = currentAnimationMode
        
        switch mode {
        case .warning:
            // ⚠️ Pulsing warning — opacity flashes like TireChangeARView step 0
            Circle()
                .stroke(TacticalTheme.danger.opacity(0.3), lineWidth: 2)
                .frame(width: animateIcon ? 130 : 80, height: animateIcon ? 130 : 80)
                .opacity(animateIcon ? 0 : 0.8)
                .position(x: centerX, y: centerY)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: false), value: animateIcon)
            
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(TacticalTheme.danger)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .opacity(animateIcon ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.7).repeatForever(), value: animateIcon)
                .glow(TacticalTheme.danger, radius: 12)
            
        case .pointDown:
            // ⬇️ Bouncing arrow + pulsing target — like TireChangeARView step 1
            Circle()
                .stroke(accentColor, lineWidth: 2)
                .frame(width: animateIcon ? 50 : 25, height: animateIcon ? 50 : 25)
                .opacity(animateIcon ? 0.2 : 1.0)
                .position(x: centerX, y: centerY + 15)
                .animation(.easeInOut(duration: 0.9).repeatForever(), value: animateIcon)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 24))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY - 30)
                .offset(y: animateIcon ? 8 : -8)
                .animation(.easeInOut(duration: 0.7).repeatForever(), value: animateIcon)
            
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY + 15)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .glow(accentColor, radius: 8)
            
        case .liftUp:
            // ⬆️ Rising motion — like TireChangeARView step 2 (jack raising)
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .offset(y: animateIcon ? -22 : 0)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: animateIcon)
                .glow(accentColor, radius: 10)
            
            Image(systemName: "arrow.up")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(accentColor.opacity(0.6))
                .position(x: centerX, y: centerY + 40)
                .offset(y: animateIcon ? -10 : 5)
                .opacity(animateIcon ? 0.3 : 0.8)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: animateIcon)
            
        case .rotate:
            // 🔄 Spinning — like TireChangeARView step 3 (lug nut rotation)
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .rotationEffect(.degrees(animateIcon ? -360 : 0))
                .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: animateIcon)
                .glow(accentColor, radius: 10)
            
            // Subtle rotation arrows around the icon
            ForEach(0..<4, id: \.self) { i in
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14))
                    .foregroundStyle(accentColor.opacity(0.3))
                    .position(x: centerX, y: centerY)
                    .offset(
                        x: cos(Double(i) * .pi / 2) * 55,
                        y: sin(Double(i) * .pi / 2) * 55
                    )
                    .rotationEffect(.degrees(animateIcon ? -360 : 0))
                    .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: animateIcon)
            }
            
        case .pressDown:
            // 👇 Press/push down — rhythmic pressing motion
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .offset(y: animateIcon ? 12 : -4)
                .scaleEffect(animateIcon ? 0.9 : 1.05)
                .animation(.easeInOut(duration: 0.5).repeatForever(), value: animateIcon)
                .glow(accentColor, radius: 8)
            
            // Impact rings
            Circle()
                .stroke(accentColor.opacity(0.2), lineWidth: 1.5)
                .frame(width: animateIcon ? 100 : 40, height: animateIcon ? 100 : 40)
                .opacity(animateIcon ? 0 : 0.6)
                .position(x: centerX, y: centerY + 20)
                .animation(.easeOut(duration: 0.6).repeatForever(autoreverses: false), value: animateIcon)
            
        case .slideIn:
            // ➡️ Slide into place — like TireChangeARView step 4 (spare mounting)
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .position(
                    x: centerX,
                    y: animateIcon ? centerY : centerY - 45
                )
                .animation(.spring(response: 1.0, dampingFraction: 0.6).repeatForever(), value: animateIcon)
                .glow(accentColor, radius: 10)
            
            // Target zone
            Circle()
                .strokeBorder(accentColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .frame(width: 60, height: 60)
                .position(x: centerX, y: centerY)
            
        case .heartbeat:
            // 💓 Rhythmic heartbeat — ~110 BPM
            Circle()
                .fill(TacticalTheme.danger.opacity(0.1))
                .frame(width: AdaptiveLayout.isIPad ? 160 : 120, height: AdaptiveLayout.isIPad ? 160 : 120)
                .scaleEffect(animateIcon ? 1.3 : 1.0)
                .opacity(animateIcon ? 0 : 0.5)
                .position(x: centerX, y: centerY)
                .animation(.easeInOut(duration: 0.545).repeatForever(autoreverses: true), value: animateIcon)
            
            Image(systemName: stepIcon)
                .font(.system(size: iconSize + 8, weight: .semibold))
                .foregroundStyle(TacticalTheme.danger)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .scaleEffect(animateIcon ? 1.18 : 0.92)
                .animation(.easeInOut(duration: 0.545).repeatForever(autoreverses: true), value: animateIcon)
                .glow(TacticalTheme.danger, radius: 14)
            
        case .scan:
            // 👁 Sweep/scan — scanning line effect
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(accentColor)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .scaleEffect(animateIcon ? 1.08 : 0.96)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
                .glow(accentColor, radius: 8)
            
            // Scanning sweep line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, accentColor.opacity(0.3), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: 120, height: 2)
                .position(x: centerX, y: centerY)
                .offset(y: animateIcon ? 40 : -40)
                .animation(.easeInOut(duration: 1.4).repeatForever(), value: animateIcon)
            
        case .wave:
            // 🌊 Bobbing/wave motion
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color(hex: "5AC8FA"))
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .offset(y: animateIcon ? -10 : 10)
                .rotationEffect(.degrees(animateIcon ? 5 : -5))
                .animation(.easeInOut(duration: 1.2).repeatForever(), value: animateIcon)
                .glow(Color(hex: "5AC8FA"), radius: 10)
            
            // Wave lines beneath
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(Color(hex: "5AC8FA").opacity(0.15))
                    .frame(width: CGFloat(80 + i * 20), height: 3)
                    .position(x: centerX, y: centerY + CGFloat(35 + i * 12))
                    .offset(x: animateIcon ? 8 : -8)
                    .animation(
                        .easeInOut(duration: 1.0 + Double(i) * 0.2).repeatForever(),
                        value: animateIcon
                    )
            }
            
        case .flicker:
            // 🔥 Flickering/heat
            Image(systemName: stepIcon)
                .font(.system(size: iconSize + 4, weight: .semibold))
                .foregroundStyle(Color(hex: "FF9500"))
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .scaleEffect(animateIcon ? 1.15 : 0.95)
                .opacity(animateIcon ? 1.0 : 0.7)
                .animation(.easeInOut(duration: 0.3).repeatForever(), value: animateIcon)
                .glow(Color(hex: "FF9500"), radius: 14)
            
            // Heat shimmer particles
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "FF9500").opacity(0.2))
                    .frame(width: 6, height: 6)
                    .position(x: centerX + CGFloat([-15, 0, 15][i]), y: centerY - 30)
                    .offset(y: animateIcon ? -20 : 0)
                    .opacity(animateIcon ? 0 : 0.5)
                    .animation(
                        .easeOut(duration: 0.8 + Double(i) * 0.15)
                            .repeatForever(autoreverses: false),
                        value: animateIcon
                    )
            }
            
        case .done:
            // ✅ Completion glow — like TireChangeARView step 5
            Image(systemName: stepIcon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color.green)
                .position(x: centerX, y: centerY)
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                .scaleEffect(animateIcon ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 0.6).repeatForever(), value: animateIcon)
                .glow(.green, radius: 12)
        }
    }
    
    // MARK: - Instruction Card
    private var genericInstructionCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: stepIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accentColor)
                
                Text("STEP \(currentStep + 1)")
                    .font(.system(size: 16, design: .monospaced).weight(.black))
                    .foregroundStyle(accentColor)
                
                Spacer()
            }
            
            Text(item.steps[currentStep])
                .font(TacticalTheme.bodyFont)
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .id(currentStep) // smooth text change
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
            
            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<item.steps.count, id: \.self) { i in
                    Circle()
                        .fill(i <= currentStep ? accentColor : TacticalTheme.textSecondary.opacity(0.3))
                        .frame(width: i == currentStep ? 8 : 5, height: i == currentStep ? 8 : 5)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
            .padding(.top, 4)
        }
        .padding(AdaptiveLayout.isIPad ? 28 : 20)
        .frame(maxWidth: AdaptiveLayout.detailMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TacticalTheme.cardBackground.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(accentColor.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, AdaptiveLayout.horizontalPadding)
    }
    
    // MARK: - Bottom Controls
    private var genericBottomControls: some View {
        HStack(spacing: 16) {
            // Previous button
            if currentStep > 0 {
                Button {
                    HapticManager.shared.tap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep -= 1
                        restartAnimation()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text("PREV")
                            .font(.system(size: 13, design: .monospaced).weight(.bold))
                    }
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(TacticalTheme.cardBackground)
                    )
                }
            }
            
            // Next / Complete button
            Button {
                if currentStep < item.steps.count - 1 {
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentStep += 1
                        restartAnimation()
                    }
                } else {
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showCompletion = true
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentStep < item.steps.count - 1 ? "NEXT STEP" : "COMPLETE")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                    Image(systemName: currentStep < item.steps.count - 1 ? "chevron.right" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(TacticalTheme.background)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(accentColor)
                )
                .glow(accentColor, radius: 6)
            }
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, AdaptiveLayout.isIPad ? 20 : 16)
        .onAppear { animateIcon = true }
    }
    
    // MARK: - Completion Overlay
    private var genericCompletionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.green)
                    .glow(.green, radius: 16)
                
                Text("PROCEDURE COMPLETE")
                    .font(.system(size: 22, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.textPrimary)
                
                Text("\(item.title) guide completed.\nStay safe and prepared.")
                    .font(TacticalTheme.bodyFont)
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    HapticManager.shared.tap()
                    dismiss()
                } label: {
                    Text("RETURN TO BASE")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.background)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(accentColor)
                        )
                        .glow(accentColor, radius: 8)
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // Reset animation flag to retrigger
    private func restartAnimation() {
        animateIcon = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateIcon = true
        }
    }
}

// MARK: - SurvivalItem Hashable Conformance
// Required for NavigationStack path-based routing.
extension SurvivalItem: Hashable {
    static func == (lhs: SurvivalItem, rhs: SurvivalItem) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
