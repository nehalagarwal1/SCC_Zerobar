import SwiftUI

// MARK: - SurvivalGridView
// Clean, focused command center. Design principles:
// - Breathing room between elements
// - Progressive disclosure (quiz/SOS are secondary)
// - One clear focal point per zone

struct SurvivalGridView: View {
    
    @State private var selectedCategory: SurvivalCategory? = nil
    @State private var showToast = false
    @State private var searchText = ""
    @State private var showQuiz = false
    @AppStorage("pinnedItems") private var pinnedItemsData: String = "1,2,5,22"
    @AppStorage("globalAudioEnabled") private var isAudioEnabled: Bool = true
    @AppStorage("quizBestScore") private var quizBestScore: Int = 0
    @AppStorage("quizBestStreak") private var quizBestStreak: Int = 0
    @AppStorage("quizAttempts") private var quizAttempts: Int = 0
    
    let namespace: Namespace.ID
    
    private var filteredItems: [SurvivalItem] {
        var items = SurvivalData.items(for: selectedCategory)
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            items = items.filter { item in
                item.title.lowercased().contains(q) ||
                item.steps.contains { $0.lowercased().contains(q) }
            }
        }
        
        return items
    }
    
    private var pinnedIDs: Set<Int> {
        Set(pinnedItemsData.split(separator: ",").compactMap { Int($0) })
    }
    
    private var pinnedItems: [SurvivalItem] {
        SurvivalData.items(for: nil).filter { pinnedIDs.contains($0.id) }
    }
    
    private func togglePin(_ id: Int) {
        var ids = pinnedIDs
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        pinnedItemsData = ids.map(String.init).joined(separator: ",")
        HapticManager.shared.tap()
    }
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Clean header ────────────────────
                hudHeader
                    .padding(.horizontal, AdaptiveLayout.hudPadding)
                    .padding(.top, AdaptiveLayout.isIPad ? 12 : 8)
                    .padding(.bottom, 12)
                
                // ── Search (compact) ────────────────
                searchBar
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                    .padding(.bottom, 12)
                
                // ── Category filter ─────────────────
                categoryFilter
                    .padding(.bottom, 14)
                
                // ── Content ─────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    if !pinnedItems.isEmpty && searchText.isEmpty && selectedCategory == nil {
                        pinnedSection
                    }
                    
                    // ── Quiz Banner ─────────────────────
                    if searchText.isEmpty {
                        quizBanner
                            .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                            .padding(.bottom, 10)
                    }
                    
                    LazyVGrid(
                        columns: AdaptiveLayout.gridItemArray(),
                        spacing: AdaptiveLayout.gridSpacing
                    ) {
                        ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                            gridCard(item: item, index: index)
                        }
                    }
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                    .padding(.bottom, 100)
                    
                    if filteredItems.isEmpty { noResultsView }
                }
            }
            ToastView(message: "MODULE OFFLINE — UNLOCK REQUIRED", isShowing: $showToast)
            ScanLinesOverlay().ignoresSafeArea()
        }
        .sheet(isPresented: $showQuiz) { QuizView() }
    }
    
    // MARK: - Grid Card (extracted to avoid type-checker issues)
    @ViewBuilder
    private func gridCard(item: SurvivalItem, index: Int) -> some View {
        if item.isLocked {
            SurvivalCardView(item: item, namespace: namespace, isPinned: pinnedIDs.contains(item.id))
                .onTapGesture { handleCardTap(item) }
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.03), value: selectedCategory)
        } else {
            NavigationLink(value: item) {
                SurvivalCardView(item: item, namespace: namespace, isPinned: pinnedIDs.contains(item.id), pinAction: { togglePin(item.id) })
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { HapticManager.shared.tap() })
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.03), value: selectedCategory)
        }
    }
    
    // MARK: - HUD Header
    // Minimal: title on left, action icons on right. No battery clutter.
    private var hudHeader: some View {
        HStack(spacing: 12) {
            // App title — anchor of the screen
            VStack(alignment: .leading, spacing: 2) {
                Text("ZERO BAR")
                    .font(.system(size: AdaptiveLayout.isIPad ? 20 : 16, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.accent)
                    .glow(TacticalTheme.accent, radius: 4)
                
                Text("\(SurvivalData.items(for: nil).count) guides • offline ready")
                    .font(.system(size: AdaptiveLayout.isIPad ? 11 : 9, design: .monospaced).weight(.medium))
                    .foregroundStyle(TacticalTheme.textSecondary.opacity(0.6))
            }
            
            Spacer()
            
            // No Signal indicator — just a small dot + text
            HStack(spacing: 4) {
                Circle()
                    .fill(TacticalTheme.danger)
                    .frame(width: 5, height: 5)
                Text("NO SIGNAL")
                    .font(.system(size: 9, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.danger.opacity(0.8))
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(TacticalTheme.textSecondary.opacity(0.6))
            
            TextField("Search guides…", text: $searchText)
                .font(.system(size: 14, design: .rounded).weight(.medium))
                .foregroundStyle(TacticalTheme.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    HapticManager.shared.tap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(TacticalTheme.cardBackground)
        )
    }
    
    // MARK: - Category Filter (clean, no counts)
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryPill(title: "All", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { selectedCategory = nil }
                        HapticManager.shared.tap()
                    }
                
                ForEach(SurvivalCategory.allCases) { category in
                    CategoryPill(title: category.rawValue, icon: category.iconName, isSelected: selectedCategory == category)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { selectedCategory = category }
                            HapticManager.shared.tap()
                        }
                }
            }
            .padding(.horizontal, AdaptiveLayout.horizontalPadding)
        }
    }
    
    // MARK: - Pinned Section (compact horizontal strip)
    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PINNED")
                .font(.system(size: 10, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
                .padding(.horizontal, AdaptiveLayout.horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(pinnedItems) { item in
                        NavigationLink(value: item) { pinnedCard(item) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AdaptiveLayout.horizontalPadding)
            }
        }
        .padding(.bottom, 14)
    }
    
    private func pinnedCard(_ item: SurvivalItem) -> some View {
        HStack(spacing: 8) {
            Image(systemName: item.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TacticalTheme.accent)
            
            Text(item.title)
                .font(.system(size: 11, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TacticalTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(TacticalTheme.accent.opacity(0.2), lineWidth: 1))
        )
    }
    
    // MARK: - No Results
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(TacticalTheme.textSecondary.opacity(0.3))
            
            Text("No guides match \"\(searchText)\"")
                .font(.system(size: 14, design: .rounded).weight(.medium))
                .foregroundStyle(TacticalTheme.textSecondary)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Quiz Banner (prominent CTA)
    private var quizBanner: some View {
        Button {
            HapticManager.shared.success()
            showQuiz = true
        } label: {
            HStack(spacing: 16) {
                // Left: Animated brain icon
                ZStack {
                    Circle()
                        .fill(TacticalTheme.accent.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(TacticalTheme.accent)
                }
                
                // Center: Title + stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("SURVIVAL QUIZ")
                        .font(.system(size: 14, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.textPrimary)
                    
                    if quizAttempts > 0 {
                        HStack(spacing: 12) {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill").font(.system(size: 9))
                                Text("Best: \(quizBestScore)/10")
                                    .font(.system(size: 10, design: .monospaced).weight(.bold))
                            }
                            .foregroundStyle(TacticalTheme.accent)
                            
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill").font(.system(size: 9))
                                Text("Streak: \(quizBestStreak)")
                                    .font(.system(size: 10, design: .monospaced).weight(.bold))
                            }
                            .foregroundStyle(Color(hex: "FF9500"))
                        }
                    } else {
                        Text("Test your emergency instincts")
                            .font(.system(size: 11, design: .rounded).weight(.medium))
                            .foregroundStyle(TacticalTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Right: Play button
                ZStack {
                    Circle()
                        .fill(TacticalTheme.accent)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TacticalTheme.background)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(TacticalTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [TacticalTheme.accent.opacity(0.4), TacticalTheme.accent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Handlers
    private func handleCardTap(_ item: SurvivalItem) {
        HapticManager.shared.heavy()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showToast = true }
    }
}

// MARK: - Category Pill (simplified — no count badge)
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: AdaptiveLayout.pillIconSize, weight: .semibold))
            
            Text(title.uppercased())
                .font(.system(size: AdaptiveLayout.pillLabelSize, design: .monospaced).weight(.bold))
        }
        .foregroundStyle(isSelected ? TacticalTheme.background : TacticalTheme.textSecondary)
        .padding(.horizontal, AdaptiveLayout.pillHorizontalPadding)
        .padding(.vertical, AdaptiveLayout.pillVerticalPadding)
        .background(
            Capsule().fill(isSelected ? TacticalTheme.accent : TacticalTheme.cardBackground)
        )
        .overlay(
            Capsule().strokeBorder(
                isSelected ? Color.clear : TacticalTheme.textSecondary.opacity(0.15),
                lineWidth: 1
            )
        )
    }
}

// MARK: - Survival Card View (clean, focused)
struct SurvivalCardView: View {
    let item: SurvivalItem
    let namespace: Namespace.ID
    var isPinned: Bool = false
    var pinAction: (() -> Void)? = nil
    
    private var categoryColor: Color {
        switch item.category {
        case .medical: return TacticalTheme.danger
        case .auto:    return TacticalTheme.accent
        case .urban:   return Color(hex: "5E9EFF")
        case .wild:    return Color(hex: "4ADE80")
        case .tools:   return Color(hex: "F59E0B")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon — single focal point
            Image(systemName: item.iconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(item.isLocked ? TacticalTheme.textSecondary : categoryColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill((item.isLocked ? TacticalTheme.textSecondary : categoryColor).opacity(0.15)))
                .matchedGeometryEffect(id: "icon_\(item.id)", in: namespace)
            
            // Title
            Text(item.title)
                .font(.system(size: AdaptiveLayout.cardTitleSize + 2, design: .monospaced).weight(.bold))
                .foregroundStyle(item.isLocked ? TacticalTheme.textSecondary : TacticalTheme.textPrimary)
                .matchedGeometryEffect(id: "title_\(item.id)", in: namespace)
                
            Spacer(minLength: 0)
            // Actions
            HStack(spacing: 12) {
                if !item.isLocked, let action = pinAction {
                    Button(action: action) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isPinned ? TacticalTheme.accent : TacticalTheme.textSecondary.opacity(0.4))
                            .frame(width: 30, height: 30)
                            // Increase tap target without changing visual size
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Chevron or lock
                Image(systemName: item.isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TacticalTheme.textSecondary.opacity(0.6))
            }
        }
        .padding(.horizontal, AdaptiveLayout.isIPad ? 18 : 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AdaptiveLayout.cardRadius, style: .continuous)
                .fill(TacticalTheme.cardBackground)
                .matchedGeometryEffect(id: "bg_\(item.id)", in: namespace)
        )
        .overlay(alignment: .leading) {
            // Subtle category accent line
            if !item.isLocked {
                RoundedRectangle(cornerRadius: 3)
                    .fill(categoryColor)
                    .frame(width: 4)
                    .padding(.vertical, 10)
                    .clipShape(RoundedRectangle(cornerRadius: AdaptiveLayout.cardRadius, style: .continuous))
            }
        }
        .opacity(item.isLocked ? 0.6 : 1.0)
    }
}
