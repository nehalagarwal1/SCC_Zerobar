import SwiftUI

// MARK: - SurvivalGridView
// The main "command center" view. Uses LazyVGrid for memory-efficient rendering
// of all 50 cards — only visible cards are in memory at any time.
// Adaptive layout: 2 columns on iPhone, 4 on iPad with scaled spacing/sizing.

struct SurvivalGridView: View {
    
    // Currently selected category filter (nil = "All")
    @State private var selectedCategory: SurvivalCategory? = nil
    
    // Toast state for locked module feedback
    @State private var showToast = false
    
    // For matchedGeometryEffect hero transition
    let namespace: Namespace.ID
    
    // Filtered item list, recomputed reactively when category changes
    private var filteredItems: [SurvivalItem] {
        SurvivalData.items(for: selectedCategory)
    }
    
    var body: some View {
        ZStack {
            // OLED-optimized true black background
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── HUD Header ──────────────────────────
                hudHeader
                    .padding(.horizontal, AdaptiveLayout.hudPadding)
                    .padding(.top, AdaptiveLayout.isIPad ? 12 : 8)
                    .padding(.bottom, AdaptiveLayout.isIPad ? 16 : 12)
                
                // ── Category Filter ─────────────────────
                categoryFilter
                    .padding(.bottom, AdaptiveLayout.isIPad ? 20 : 16)
                
                // ── Grid ────────────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: AdaptiveLayout.gridItemArray(),
                        spacing: AdaptiveLayout.gridSpacing
                    ) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            if item.isLocked {
                                // Locked: tap triggers heavy haptic + toast
                                SurvivalCardView(
                                    item: item,
                                    namespace: namespace
                                )
                                .onTapGesture {
                                    handleCardTap(item)
                                }
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.03),
                                    value: selectedCategory
                                )
                            } else {
                                // Unlocked: NavigationLink pushes to detail view
                                NavigationLink(value: item) {
                                    SurvivalCardView(
                                        item: item,
                                        namespace: namespace
                                    )
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(TapGesture().onEnded {
                                    HapticManager.shared.tap()
                                })
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.03),
                                    value: selectedCategory
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                    .padding(.bottom, 100)
                }
            }
            
            // ── Toast Overlay ───────────────────────
            ToastView(message: "MODULE OFFLINE — UNLOCK REQUIRED", isShowing: $showToast)
            
            // Subtle scan line overlay for tactical feel
            ScanLinesOverlay()
                .ignoresSafeArea()
        }
    }
    
    // MARK: - HUD Header
    // Mimics a heads-up display with battery readout and signal status.
    // Scaled up on iPad for better readability at arm's length.
    private var hudHeader: some View {
        HStack {
            // Battery indicator (mock data — no actual battery API needed)
            HStack(spacing: 6) {
                Image(systemName: "battery.75percent")
                    .font(.system(size: AdaptiveLayout.hudIconSize, weight: .semibold))
                    .foregroundStyle(TacticalTheme.accent)
                
                Text("87%")
                    .font(.system(size: AdaptiveLayout.isIPad ? 14 : 12, design: .monospaced))
                    .foregroundStyle(TacticalTheme.textSecondary)
            }
            
            Spacer()
            
            // App title — small and tactical
            Text("ZERO BAR")
                .font(.system(size: AdaptiveLayout.hudTitleSize, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.accent)
                .glow(TacticalTheme.accent, radius: 4)
            
            Spacer()
            
            // No Signal badge
            HStack(spacing: 5) {
                Circle()
                    .fill(TacticalTheme.danger)
                    .frame(width: AdaptiveLayout.isIPad ? 8 : 6, height: AdaptiveLayout.isIPad ? 8 : 6)
                    .overlay(
                        Circle()
                            .fill(TacticalTheme.danger)
                            .frame(width: AdaptiveLayout.isIPad ? 8 : 6, height: AdaptiveLayout.isIPad ? 8 : 6)
                            .scaleEffect(1.8)
                            .opacity(0.3)
                    )
                
                Text("NO SIGNAL")
                    .font(.system(size: AdaptiveLayout.isIPad ? 12 : 10, design: .monospaced).weight(.bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, AdaptiveLayout.isIPad ? 14 : 10)
            .padding(.vertical, AdaptiveLayout.isIPad ? 7 : 5)
            .background(
                Capsule()
                    .fill(TacticalTheme.danger.opacity(0.25))
                    .overlay(
                        Capsule()
                            .strokeBorder(TacticalTheme.danger.opacity(0.6), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Category Filter
    // Horizontal scrolling segmented control. "All" + 5 categories.
    // On iPad, pills are larger with more generous touch targets.
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AdaptiveLayout.isIPad ? 14 : 10) {
                // "All" button
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedCategory = nil
                    }
                    HapticManager.shared.tap()
                }
                
                // Category buttons
                ForEach(SurvivalCategory.allCases) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedCategory = category
                        }
                        HapticManager.shared.tap()
                    }
                }
            }
            .padding(.horizontal, AdaptiveLayout.horizontalPadding)
        }
    }
    
    // MARK: - Card Tap Handler (Locked items only)
    private func handleCardTap(_ item: SurvivalItem) {
        // Heavy haptic + error toast for locked modules
        HapticManager.shared.heavy()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showToast = true
        }
    }
}

// MARK: - Category Pill Button
// Responsive pill with adaptive sizing for iPad's larger screens.
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: AdaptiveLayout.isIPad ? 8 : 6) {
            Image(systemName: icon)
                .font(.system(size: AdaptiveLayout.pillIconSize, weight: .semibold))
            
            Text(title.uppercased())
                .font(.system(size: AdaptiveLayout.pillLabelSize, design: .monospaced).weight(.bold))
        }
        .foregroundStyle(isSelected ? TacticalTheme.background : TacticalTheme.textSecondary)
        .padding(.horizontal, AdaptiveLayout.pillHorizontalPadding)
        .padding(.vertical, AdaptiveLayout.pillVerticalPadding)
        .background(
            Capsule()
                .fill(isSelected ? TacticalTheme.accent : TacticalTheme.cardBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? Color.clear : TacticalTheme.textSecondary.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Survival Card View
// Individual grid card. Uses matchedGeometryEffect for hero transitions.
// Scales icon size, card height, and corner radius for iPad.
struct SurvivalCardView: View {
    let item: SurvivalItem
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: AdaptiveLayout.isIPad ? 16 : 12) {
            Spacer()
            
            // Large SF Symbol — zero asset cost, scales infinitely
            ZStack {
                Image(systemName: item.iconName)
                    .font(.system(size: AdaptiveLayout.cardIconSize, weight: .semibold))
                    .foregroundStyle(
                        item.isLocked
                            ? TacticalTheme.textSecondary
                            : TacticalTheme.accent
                    )
                    .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
                
                // Lock overlay for locked items
                if item.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: AdaptiveLayout.isIPad ? 18 : 14, weight: .bold))
                        .foregroundStyle(TacticalTheme.danger.opacity(0.8))
                        .offset(x: AdaptiveLayout.isIPad ? 24 : 18, y: AdaptiveLayout.isIPad ? -22 : -16)
                }
            }
            
            Spacer()
            
            // Item title
            Text(item.title)
                .font(.system(size: AdaptiveLayout.cardTitleSize, design: .monospaced).weight(.semibold))
                .foregroundStyle(
                    item.isLocked
                        ? TacticalTheme.textSecondary
                        : TacticalTheme.textPrimary
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .matchedGeometryEffect(id: "title_\(item.id)", in: namespace)
        }
        .padding(AdaptiveLayout.isIPad ? 18 : 14)
        .frame(maxWidth: .infinity)
        .frame(height: AdaptiveLayout.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: AdaptiveLayout.cardRadius, style: .continuous)
                .fill(TacticalTheme.cardBackground)
                .matchedGeometryEffect(id: "bg_\(item.id)", in: namespace)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AdaptiveLayout.cardRadius, style: .continuous)
                .strokeBorder(
                    item.isLocked
                        ? Color.clear
                        : TacticalTheme.accent.opacity(0.2),
                    lineWidth: 1
                )
        )
        .opacity(item.isLocked ? 0.5 : 1.0)
        .scaleEffect(item.isLocked ? 0.98 : 1.0)
    }
}
