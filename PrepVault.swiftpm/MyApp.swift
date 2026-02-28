import SwiftUI

// MARK: - App Entry Point
// Using the modern SwiftUI App lifecycle (@main struct).
// Forces dark mode globally for OLED optimization.

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Enforce dark mode across the entire app.
                // This ensures even system sheets and alerts use our dark theme.
                .preferredColorScheme(.dark)
        }
    }
}
