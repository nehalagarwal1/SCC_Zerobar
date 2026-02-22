import SwiftUI

// MARK: - Tactical OS Design System
// Centralized design tokens ensure visual consistency across all views.
// Using an enum (no cases) as a pure namespace — cannot be instantiated.

enum TacticalTheme {
    
    // MARK: Colors
    // True black for OLED power savings; Safety Yellow for high-contrast active elements.
    static let background     = Color.black
    static let accent         = Color(hex: "FFD700")   // Safety Yellow
    static let cardBackground = Color(hex: "1C1C1E")   // System Dark Gray
    static let danger         = Color(hex: "FF3B30")    // iOS System Red
    static let textPrimary    = Color.white
    static let textSecondary  = Color(hex: "8E8E93")   // System Gray
    
    // MARK: Typography
    // Rounded headlines create approachable feel; monospaced for data readouts.
    static let headline    = Font.system(.largeTitle, design: .rounded, weight: .black)
    static let title       = Font.system(.title2, design: .rounded, weight: .bold)
    static let title3      = Font.system(.title3, design: .rounded, weight: .semibold)
    static let bodyFont    = Font.system(.body, design: .rounded, weight: .medium)
    static let caption     = Font.system(.caption, design: .monospaced)
    static let captionBold = Font.system(.caption2, design: .monospaced, weight: .bold)
}

// MARK: - Color Hex Initializer
// Avoids importing any third-party library for hex color parsing.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (255, 215, 0, 255) // Fallback to Safety Yellow
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Haptic Manager
// Wrapping UIKit haptics in a MainActor-isolated class for Swift 6 Sendable safety.
// Using UIImpactFeedbackGenerator for fine-grained control over haptic intensity.
@MainActor
final class HapticManager: Sendable {
    static let shared = HapticManager()
    private init() {}
    
    func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - Toast View
// Reusable "Module Offline" notification overlay.
// Uses spring animation for organic, non-mechanical feel.
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(TacticalTheme.danger)
                    
                    Text(message)
                        .font(TacticalTheme.captionBold)
                        .foregroundStyle(TacticalTheme.textPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(TacticalTheme.cardBackground)
                        .overlay(
                            Capsule()
                                .strokeBorder(TacticalTheme.danger.opacity(0.4), lineWidth: 1)
                        )
                )
                .shadow(color: TacticalTheme.danger.opacity(0.3), radius: 12, y: 4)
                .padding(.bottom, 40)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                // Auto-dismiss after 1.8 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// MARK: - Glow Effect Modifier
// Reusable neon glow for active/accent elements.
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
}

extension View {
    func glow(_ color: Color = TacticalTheme.accent, radius: CGFloat = 8) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Scan Line Effect
// CRT-style horizontal scan line overlay for the tactical aesthetic.
struct ScanLinesOverlay: View {
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 3) {
                ForEach(0..<Int(geo.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.03))
                        .frame(height: 1)
                    Spacer(minLength: 0)
                }
            }
        }
        .allowsHitTesting(false) // Pass through all touches
    }
}

// MARK: - Adaptive Layout
// Centralized device-detection and responsive metrics.
// Uses UIDevice idiom check — works on both real devices and simulators.
// All layout constants are computed properties for iPad vs iPhone.
enum AdaptiveLayout {
    
    /// True when running on iPad (any model)
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: Grid
    /// Number of columns in the survival module grid
    static var gridColumns: Int { isIPad ? 4 : 2 }
    /// Spacing between grid items
    static var gridSpacing: CGFloat { isIPad ? 20 : 14 }
    /// Card height in the grid
    static var cardHeight: CGFloat { isIPad ? 200 : 150 }
    /// Card corner radius
    static var cardRadius: CGFloat { isIPad ? 20 : 16 }
    /// Card icon size
    static var cardIconSize: CGFloat { isIPad ? 48 : 36 }
    /// Card title font size
    static var cardTitleSize: CGFloat { isIPad ? 14 : 12 }
    
    // MARK: Padding
    /// Horizontal padding for the main content area
    static var horizontalPadding: CGFloat { isIPad ? 32 : 16 }
    /// Horizontal inset for the HUD bar
    static var hudPadding: CGFloat { isIPad ? 32 : 20 }
    
    // MARK: Detail Views
    /// Max width for detail content to avoid excessive line lengths on iPad
    static var detailMaxWidth: CGFloat { isIPad ? 700 : .infinity }
    
    // MARK: Category Filter
    /// Pill horizontal padding
    static var pillHorizontalPadding: CGFloat { isIPad ? 20 : 14 }
    /// Pill vertical padding
    static var pillVerticalPadding: CGFloat { isIPad ? 12 : 9 }
    /// Pill icon size
    static var pillIconSize: CGFloat { isIPad ? 14 : 12 }
    /// Pill label size
    static var pillLabelSize: CGFloat { isIPad ? 13 : 11 }
    
    // MARK: HUD Header
    /// Battery icon size
    static var hudIconSize: CGFloat { isIPad ? 18 : 14 }
    /// Title font size
    static var hudTitleSize: CGFloat { isIPad ? 16 : 13 }
    
    // MARK: Typography Scaling
    /// Scale factor for body text on iPad
    static var bodyScale: CGFloat { isIPad ? 1.15 : 1.0 }
    
    /// Builds the adaptive grid column array
    static func gridItemArray() -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: gridSpacing),
            count: gridColumns
        )
    }
}

// MARK: - Step Icon Mapper
// Automatically assigns an SF Symbol to each instruction step based on
// keyword analysis. Priority-ordered: most specific matches first.
// Zero asset cost — all icons ship with iOS.

enum StepIconMapper {
    
    /// Returns a context-appropriate SF Symbol name for a given step string.
    static func icon(for step: String) -> String {
        let s = step.lowercased()
        
        // ── Emergency & Communication ──────────────────
        if s.contains("911") || s.contains("call emergency") || s.contains("call for help")
            { return "phone.arrow.up.right.fill" }
        if s.contains("epipen") || s.contains("epinephrine") || s.contains("syringe")
            { return "syringe.fill" }
        if s.contains("cpr") || s.contains("compressions") || s.contains("chest")
            { return "heart.fill" }
        if s.contains("rescue breath") || s.contains("airway") || s.contains("breathe") || s.contains("breathing")
            { return "lungs.fill" }
        if s.contains("tourniquet") || s.contains("bleed") || s.contains("blood") || s.contains("pressure")
            { return "drop.fill" }
        if s.contains("splint") || s.contains("fracture") || s.contains("immobilize")
            { return "bandage.fill" }
        
        // ── Water & Swimming ───────────────────────────
        if s.contains("swim") || s.contains("rip current") || s.contains("float") || s.contains("drown")
            { return "figure.pool.swim" }
        if s.contains("purify") || (s.contains("boil") && s.contains("water"))
            { return "drop.triangle.fill" }
        if s.contains("water") || s.contains("hydrat") || s.contains("drink") || s.contains("fluid")
            { return "drop.fill" }
        
        // ── Fire & Heat ────────────────────────────────
        if s.contains("fire") || s.contains("flame") || s.contains("ignite") || s.contains("torch")
            { return "flame.fill" }
        if s.contains("heat stroke") || s.contains("overheat") || s.contains("temperature")
            { return "thermometer.sun.fill" }
        if s.contains("cool") || s.contains("ice") || s.contains("cold pack")
            { return "snowflake" }
        if s.contains("burn")
            { return "flame.fill" }
        
        // ── Shelter & Cover ────────────────────────────
        if s.contains("shelter") || s.contains("indoor") || s.contains("building")
            { return "house.fill" }
        if s.contains("tent") || s.contains("tarp") || s.contains("blanket")
            { return "tent.fill" }
        
        // ── Vehicle ────────────────────────────────────
        if s.contains("drive") || s.contains("vehicle") || s.contains("car ") || s.contains("engine")
            { return "car.fill" }
        if s.contains("tire") || s.contains("wheel") || s.contains("jack")
            { return "circle.circle.fill" }
        if s.contains("battery") || s.contains("jump start") || s.contains("cable")
            { return "battery.100.bolt" }
        
        // ── Navigation ─────────────────────────────────
        if s.contains("north") || s.contains("south") || s.contains("compass") || s.contains("direction")
            { return "location.north.fill" }
        if s.contains("star") || s.contains("polaris") || s.contains("constellation") || s.contains("orion")
            { return "star.fill" }
        if s.contains("map") || s.contains("route") || s.contains("navigate")
            { return "map.fill" }
        
        // ── Food & Plants ──────────────────────────────
        if s.contains("edible") || s.contains("plant") || s.contains("forag") || s.contains("berry")
            { return "leaf.fill" }
        if s.contains("food") || s.contains("meal") || s.contains("eat ")
            { return "fork.knife" }
        
        // ── Animals ────────────────────────────────────
        if s.contains("bear") || s.contains("animal") || s.contains("snake") || s.contains("dog")
            { return "pawprint.fill" }
        if s.contains("insect") || s.contains("sting") || s.contains("bee") || s.contains("spider") || s.contains("bite")
            { return "ant.fill" }
        
        // ── Signals & Communication ────────────────────
        if s.contains("whistle") || s.contains("signal") || s.contains("sos") || s.contains("distress")
            { return "antenna.radiowaves.left.and.right" }
        if s.contains("mirror") || s.contains("reflect") || s.contains("flash")
            { return "sun.max.fill" }
        if s.contains("radio") || s.contains("broadcast") || s.contains("frequency")
            { return "radio.fill" }
        
        // ── Body Position & Movement ───────────────────
        if s.contains("lie ") || s.contains("lay ") || s.contains("on your back") || s.contains("recovery position")
            { return "figure.roll" }
        if s.contains("crouch") || s.contains("kneel") || s.contains("curl") || s.contains("ball")
            { return "figure.fall" }
        if s.contains("run ") || s.contains("escape") || s.contains("evacuate") || s.contains("leave")
            { return "figure.walk" }
        if s.contains("move") || s.contains("pull") || s.contains("push") || s.contains("carry")
            { return "arrow.right" }
        
        // ── Hands & Manual Actions ─────────────────────
        if s.contains("grip") || s.contains("hold") || s.contains("grab") || s.contains("squeeze")
            { return "hand.raised.fill" }
        if s.contains("wrap") || s.contains("tie") || s.contains("knot") || s.contains("secure") || s.contains("rope")
            { return "link" }
        if s.contains("cut") || s.contains("scrape") || s.contains("strip")
            { return "scissors" }
        if s.contains("clean") || s.contains("wash") || s.contains("hygien") || s.contains("sanit")
            { return "hands.sparkles.fill" }
        
        // ── Tools & Equipment ──────────────────────────
        if s.contains("kit") || s.contains("supply") || s.contains("equipment") || s.contains("gear")
            { return "cross.case.fill" }
        if s.contains("tape") || s.contains("repair") || s.contains("patch") || s.contains("fix")
            { return "wrench.fill" }
        
        // ── Weather ────────────────────────────────────
        if s.contains("tornado") || s.contains("hurricane") || s.contains("storm")
            { return "cloud.bolt.fill" }
        if s.contains("rain") || s.contains("flood")
            { return "cloud.rain.fill" }
        if s.contains("snow") || s.contains("avalanche") || s.contains("blizzard")
            { return "cloud.snow.fill" }
        if s.contains("lightning") || s.contains("thunder") || s.contains("struck")
            { return "bolt.fill" }
        
        // ── Safety & Warnings ──────────────────────────
        if s.contains("do not") || s.contains("don't") || s.contains("never") || s.contains("avoid")
            { return "exclamationmark.triangle.fill" }
        if s.contains("danger") || s.contains("warning") || s.contains("caution")
            { return "exclamationmark.shield.fill" }
        
        // ── Observation & Monitoring ───────────────────
        if s.contains("check") || s.contains("inspect") || s.contains("look") || s.contains("monitor")
            { return "eye.fill" }
        if s.contains("recognize") || s.contains("identify") || s.contains("symptom")
            { return "magnifyingglass" }
        if s.contains("wait") || s.contains("minute") || s.contains("hour") || s.contains("second")
            { return "clock.fill" }
        
        // ── Clothing ───────────────────────────────────
        if s.contains("clothing") || s.contains("wear") || s.contains("sleeve")
            { return "tshirt.fill" }
        if s.contains("shoe") || s.contains("boot") || s.contains("sock") || s.contains("feet")
            { return "shoe.fill" }
        
        // ── Default ────────────────────────────────────
        return "checkmark.circle.fill"
    }
    
    /// Returns a contextual accent color for the icon based on urgency/type.
    static func iconColor(for step: String) -> Color {
        let s = step.lowercased()
        if s.contains("911") || s.contains("do not") || s.contains("don't") || s.contains("never")
            || s.contains("danger") || s.contains("immediately") || s.contains("warning")
            { return TacticalTheme.danger }
        if s.contains("fire") || s.contains("flame") || s.contains("burn") || s.contains("heat")
            { return Color(hex: "FF9500") }
        if s.contains("water") || s.contains("swim") || s.contains("flood") || s.contains("rain")
            { return Color(hex: "5AC8FA") }
        if s.contains("plant") || s.contains("edible") || s.contains("hygien") || s.contains("clean")
            { return Color(hex: "34C759") }
        return TacticalTheme.accent
    }
}

