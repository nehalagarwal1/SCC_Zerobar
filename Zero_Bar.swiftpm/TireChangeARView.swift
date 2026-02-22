import SwiftUI

// MARK: - TireChangeARView
// Interactive tire-change walkthrough with rich programmatic visuals.
// Uses SwiftUI shapes exclusively — zero image assets, ARKit-free for
// guaranteed compatibility with Swift Playgrounds on iPad.
//
// Design rationale: Instead of requiring ARKit (which fails in Playgrounds),
// we build an immersive schematic experience using SwiftUI Canvas, shapes,
// and animations. This approach is both lighter (<25MB) and more reliable.

struct TireChangeARView: View {
    
    // Current step in the tire change sequence
    @State private var currentStep = 0
    @State private var animateArrow = false
    @State private var showCompletion = false
    @Environment(\.dismiss) private var dismiss
    
    let namespace: Namespace.ID
    let item: SurvivalItem
    
    // Step data with instructions and focus areas
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
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Top Bar ─────────────────────────
                topBar
                
                // ── Schematic Visualization ─────────
                schematicView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // ── Instruction HUD Card ────────────
                instructionCard
                
                // ── Navigation Controls ─────────────
                bottomControls
            }
            
            // Completion overlay
            if showCompletion {
                completionOverlay
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
            
            // Step counter
            Text("\(currentStep + 1) / \(steps.count)")
                .font(TacticalTheme.caption)
                .foregroundStyle(TacticalTheme.textSecondary)
            
            Spacer()
            
            // AR badge (decorative — signals the AR-ready architecture)
            HStack(spacing: 4) {
                Image(systemName: "arkit")
                    .font(.system(size: 12, weight: .semibold))
                Text("SCHEMATIC")
                    .font(.system(size: 10, design: .monospaced).weight(.bold))
            }
            .foregroundStyle(TacticalTheme.accent.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(TacticalTheme.accent.opacity(0.1))
            )
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, AdaptiveLayout.isIPad ? 16 : 12)
    }
    
    // MARK: - Schematic Visualization
    // Programmatic car schematic drawn with SwiftUI shapes.
    // Each step highlights a different area of the vehicle.
    private var schematicView: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Grid background for technical feel
                gridBackground(width: w, height: h)
                
                // Car body outline
                carBody(width: w, height: h)
                
                // Step-specific annotations
                stepAnnotation(width: w, height: h)
            }
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
    }
    
    // Technical grid background
    private func gridBackground(width: CGFloat, height: CGFloat) -> some View {
        Canvas { context, size in
            let gridSpacing: CGFloat = AdaptiveLayout.isIPad ? 50 : 30
            let lineColor = Color.white.opacity(0.04)
            
            // Vertical lines
            var x: CGFloat = 0
            while x <= size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                x += gridSpacing
            }
            
            // Horizontal lines
            var y: CGFloat = 0
            while y <= size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                y += gridSpacing
            }
        }
    }
    
    // Simplified side-view car outline using SwiftUI shapes
    private func carBody(width: CGFloat, height: CGFloat) -> some View {
        let centerX = width / 2
        let centerY = height / 2
        
        return ZStack {
            // Car body shape
            CarShape()
                .stroke(TacticalTheme.accent.opacity(0.5), lineWidth: 2)
                .frame(width: AdaptiveLayout.isIPad ? width * 0.6 : width * 0.75, height: height * 0.35)
                .position(x: centerX, y: centerY - 10)
            
            // Front wheel
            Circle()
                .stroke(TacticalTheme.textSecondary.opacity(0.6), lineWidth: AdaptiveLayout.isIPad ? 3 : 2)
                .frame(width: AdaptiveLayout.isIPad ? 70 : 50, height: AdaptiveLayout.isIPad ? 70 : 50)
                .position(x: centerX - width * 0.22, y: centerY + height * 0.12)
            
            Circle()
                .fill(TacticalTheme.textSecondary.opacity(0.15))
                .frame(width: AdaptiveLayout.isIPad ? 44 : 30, height: AdaptiveLayout.isIPad ? 44 : 30)
                .position(x: centerX - width * 0.22, y: centerY + height * 0.12)
            
            // Rear wheel (the flat one)
            Circle()
                .stroke(
                    currentStep >= 3 ? TacticalTheme.danger : TacticalTheme.textSecondary.opacity(0.6),
                    lineWidth: currentStep >= 3 ? 3 : 2
                )
                .frame(width: AdaptiveLayout.isIPad ? 70 : 50, height: AdaptiveLayout.isIPad ? 70 : 50)
                .position(x: centerX + width * 0.22, y: centerY + height * 0.12)
            
            Circle()
                .fill(
                    currentStep >= 3
                        ? TacticalTheme.danger.opacity(0.15)
                        : TacticalTheme.textSecondary.opacity(0.15)
                )
                .frame(width: AdaptiveLayout.isIPad ? 44 : 30, height: AdaptiveLayout.isIPad ? 44 : 30)
                .position(x: centerX + width * 0.22, y: centerY + height * 0.12)
            
            // Lug nuts on rear wheel (visible in steps 3-4)
            if currentStep >= 3 && currentStep <= 4 {
                ForEach(0..<5, id: \.self) { i in
                    let angle = (Double(i) * 72 - 90) * .pi / 180
                    let radius: CGFloat = 15
                    Circle()
                        .fill(TacticalTheme.accent)
                        .frame(width: 5, height: 5)
                        .position(
                            x: centerX + width * 0.22 + cos(angle) * radius,
                            y: centerY + height * 0.12 + sin(angle) * radius
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Ground line
            Rectangle()
                .fill(TacticalTheme.textSecondary.opacity(0.2))
                .frame(width: width * 0.85, height: 1)
                .position(x: centerX, y: centerY + height * 0.19)
        }
        .animation(.easeInOut(duration: 0.5), value: currentStep)
    }
    
    // Step-specific animated annotations
    @ViewBuilder
    private func stepAnnotation(width: CGFloat, height: CGFloat) -> some View {
        let centerX = width / 2
        let centerY = height / 2
        
        switch currentStep {
        case 0:
            // Chock indicators behind rear wheel
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundStyle(TacticalTheme.accent)
                .position(x: centerX + width * 0.35, y: centerY + height * 0.12)
                .glow(TacticalTheme.accent, radius: 10)
                .opacity(animateArrow ? 1 : 0.4)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: animateArrow)
            
        case 1:
            // Jack point indicator — pulsing circle beneath car
            Circle()
                .stroke(TacticalTheme.accent, lineWidth: 2)
                .frame(width: animateArrow ? 40 : 20, height: animateArrow ? 40 : 20)
                .position(x: centerX + width * 0.13, y: centerY + height * 0.14)
                .opacity(animateArrow ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.9).repeatForever(), value: animateArrow)
            
            // Arrow pointing to jack point
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 20))
                .foregroundStyle(TacticalTheme.accent)
                .position(x: centerX + width * 0.13, y: centerY + height * 0.04)
                .offset(y: animateArrow ? 5 : -5)
                .animation(.easeInOut(duration: 0.7).repeatForever(), value: animateArrow)
            
            // Label
            Text("JACK POINT")
                .font(.system(size: 10, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.accent)
                .position(x: centerX + width * 0.13, y: centerY - height * 0.04)
                .glow(TacticalTheme.accent, radius: 4)
            
        case 2:
            // Jack raising animation — arrow going up
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(TacticalTheme.accent)
                .position(x: centerX + width * 0.13, y: centerY + height * 0.18)
                .offset(y: animateArrow ? -20 : 0)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: animateArrow)
                .glow(TacticalTheme.accent, radius: 10)
            
        case 3:
            // Counter-clockwise rotation indicator on lug nuts
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(TacticalTheme.accent)
                .position(x: centerX + width * 0.35, y: centerY + height * 0.02)
                .rotationEffect(.degrees(animateArrow ? -360 : 0))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: animateArrow)
            
        case 4:
            // Spare tire being placed — moving into position
            Circle()
                .stroke(TacticalTheme.accent, lineWidth: 3)
                .frame(width: 50, height: 50)
                .position(
                    x: centerX + width * 0.22,
                    y: animateArrow
                        ? centerY + height * 0.12
                        : centerY - height * 0.05
                )
                .animation(.spring(response: 1.0, dampingFraction: 0.6).repeatForever(), value: animateArrow)
            
            Text("SPARE")
                .font(.system(size: 10, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.accent)
                .position(
                    x: centerX + width * 0.22,
                    y: animateArrow
                        ? centerY + height * 0.12
                        : centerY - height * 0.05
                )
                .animation(.spring(response: 1.0, dampingFraction: 0.6).repeatForever(), value: animateArrow)
            
        case 5:
            // Final torque check — checkmark
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.green)
                .position(x: centerX + width * 0.22, y: centerY + height * 0.12)
                .scaleEffect(animateArrow ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 0.6).repeatForever(), value: animateArrow)
                .glow(.green, radius: 12)
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - Instruction Card
    // Semi-transparent HUD card showing the current step instructions.
    private var instructionCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(TacticalTheme.accent)
                
                Text(steps[currentStep].title)
                    .font(.system(size: 16, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.accent)
                
                Spacer()
            }
            
            Text(steps[currentStep].instruction)
                .font(TacticalTheme.bodyFont)
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i <= currentStep ? TacticalTheme.accent : TacticalTheme.textSecondary.opacity(0.3))
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
                        .strokeBorder(TacticalTheme.accent.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, AdaptiveLayout.horizontalPadding)
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
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
                if currentStep < steps.count - 1 {
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
                    Text(currentStep < steps.count - 1 ? "NEXT STEP" : "COMPLETE")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                    Image(systemName: currentStep < steps.count - 1 ? "chevron.right" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(TacticalTheme.background)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(TacticalTheme.accent)
                )
                .glow(TacticalTheme.accent, radius: 6)
            }
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, AdaptiveLayout.isIPad ? 20 : 16)
        .onAppear { animateArrow = true }
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
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
                
                Text("Tire successfully changed.\nDrive to nearest service center to replace spare.")
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
                                .fill(TacticalTheme.accent)
                        )
                        .glow(TacticalTheme.accent, radius: 8)
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // Reset animation flag to retrigger
    private func restartAnimation() {
        animateArrow = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateArrow = true
        }
    }
}

// MARK: - Car Shape
// Custom SwiftUI Shape for the vehicle side profile.
// Drawn procedurally — zero asset cost, infinite resolution.
struct CarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Bottom left
        path.move(to: CGPoint(x: w * 0.05, y: h * 0.75))
        
        // Front bumper
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.65))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.55),
            control: CGPoint(x: w * 0.02, y: h * 0.55)
        )
        
        // Hood
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.5))
        
        // Windshield
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.2))
        
        // Roof
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.18))
        
        // Rear glass
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.45))
        
        // Trunk
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.5))
        
        // Rear bumper
        path.addQuadCurve(
            to: CGPoint(x: w * 0.98, y: h * 0.65),
            control: CGPoint(x: w * 0.98, y: h * 0.5)
        )
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.75))
        
        // Bottom
        path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.75))
        
        return path
    }
}
