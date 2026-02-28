import SwiftUI

// MARK: - ContentView
// Root navigation controller using NavigationStack.
// Shows onboarding on first launch, then the main grid.

struct ContentView: View {
    
    @Namespace private var heroNamespace
    @State private var navigationPath = NavigationPath()
    
    // Persisted across launches — onboarding shows only once
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            NavigationStack(path: $navigationPath) {
                SurvivalGridView(namespace: heroNamespace)
                    .navigationBarHidden(true)
                    .navigationDestination(for: SurvivalItem.self) { item in
                        destinationView(for: item)
                    }
            }
            .preferredColorScheme(.dark)
            .transition(.opacity)
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .preferredColorScheme(.dark)
                .transition(.opacity)
        }
    }
    
    // MARK: - Routing
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
            SceneGuideView(namespace: heroNamespace, item: item)
                .navigationBarHidden(true)
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
