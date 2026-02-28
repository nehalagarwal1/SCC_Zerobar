import SwiftUI

// MARK: - Emergency SOS View
// One-tap access to emergency services worldwide.
// Shows regional emergency numbers and attempts to dial even with weak signal.
// Uses tel: URL scheme (Apple framework, no external dependency).

struct EmergencySOSView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDialConfirm = false
    @State private var selectedNumber = ""
    @State private var pulseRing = false
    
    private let emergencyNumbers: [(region: String, number: String, flag: String)] = [
        ("USA / Canada", "911", "🇺🇸"),
        ("Europe (EU)", "112", "🇪🇺"),
        ("United Kingdom", "999", "🇬🇧"),
        ("India", "112", "🇮🇳"),
        ("Australia", "000", "🇦🇺"),
        ("Japan", "119", "🇯🇵"),
        ("China", "120", "🇨🇳"),
        ("Brazil", "192", "🇧🇷"),
        ("Mexico", "911", "🇲🇽"),
        ("South Korea", "119", "🇰🇷")
    ]
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                sosHeader
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        signalNotice
                        sosMainButton
                        emergencyNumbersList
                        tipsSection
                    }
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                    .padding(.bottom, 40)
                }
            }
            
            ScanLinesOverlay().ignoresSafeArea()
        }
        .alert("Dial Emergency?", isPresented: $showDialConfirm) {
            Button("Call \(selectedNumber)", role: .destructive) { dialNumber(selectedNumber) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will attempt to call \(selectedNumber). Emergency calls may go through even without cell signal.")
        }
    }
    
    // MARK: - Header
    private var sosHeader: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold))
                    Text("BACK").font(.system(size: 12, design: .monospaced).weight(.bold))
                }.foregroundStyle(TacticalTheme.textSecondary)
            }
            Spacer()
            Text("EMERGENCY SOS")
                .font(.system(size: 14, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.danger)
                .glow(TacticalTheme.danger, radius: 4)
            Spacer()
            // Invisible spacer for balance
            HStack(spacing: 6) {
                Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold))
                Text("BACK").font(.system(size: 12, design: .monospaced).weight(.bold))
            }.opacity(0)
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, 12)
    }
    
    // MARK: - Signal Notice
    private var signalNotice: some View {
        HStack(spacing: 10) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(TacticalTheme.accent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("EMERGENCY CALLS MAY STILL WORK")
                    .font(.system(size: 11, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.accent)
                Text("Even with no signal bars, emergency calls can connect through any available carrier network.")
                    .font(.system(size: 12, design: .rounded).weight(.medium))
                    .foregroundStyle(TacticalTheme.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TacticalTheme.accent.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(TacticalTheme.accent.opacity(0.2), lineWidth: 1))
        )
        .padding(.top, 8)
    }
    
    // MARK: - Main SOS Button
    private var sosMainButton: some View {
        Button {
            HapticManager.shared.heavy()
            selectedNumber = "911"
            showDialConfirm = true
        } label: {
            ZStack {
                // Pulse rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(TacticalTheme.danger.opacity(0.2), lineWidth: 2)
                        .frame(width: pulseRing ? CGFloat(160 + i * 30) : CGFloat(120 + i * 15),
                               height: pulseRing ? CGFloat(160 + i * 30) : CGFloat(120 + i * 15))
                        .opacity(pulseRing ? 0 : 0.6)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(Double(i) * 0.3), value: pulseRing)
                }
                
                Circle()
                    .fill(TacticalTheme.danger)
                    .frame(width: 120, height: 120)
                    .shadow(color: TacticalTheme.danger.opacity(0.5), radius: 20)
                
                VStack(spacing: 4) {
                    Image(systemName: "sos")
                        .font(.system(size: 32, weight: .black))
                    Text("TAP TO CALL")
                        .font(.system(size: 9, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 20)
        .onAppear { pulseRing = true }
        .accessibilityLabel("Emergency SOS. Double tap to call 911")
    }
    
    // MARK: - Emergency Numbers
    private var emergencyNumbersList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WORLDWIDE EMERGENCY NUMBERS")
                .font(.system(size: 11, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textSecondary)
            
            ForEach(emergencyNumbers, id: \.number) { entry in
                emergencyRow(entry)
            }
        }
    }
    
    private func emergencyRow(_ entry: (region: String, number: String, flag: String)) -> some View {
        Button {
            HapticManager.shared.tap()
            selectedNumber = entry.number
            showDialConfirm = true
        } label: {
            HStack(spacing: 14) {
                Text(entry.flag)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.region)
                        .font(.system(size: 13, design: .rounded).weight(.semibold))
                        .foregroundStyle(TacticalTheme.textPrimary)
                    Text(entry.number)
                        .font(.system(size: 18, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.danger)
                }
                
                Spacer()
                
                Image(systemName: "phone.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(TacticalTheme.danger)
                    .padding(10)
                    .background(Circle().fill(TacticalTheme.danger.opacity(0.15)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TacticalTheme.cardBackground)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(TacticalTheme.danger.opacity(0.1), lineWidth: 1))
            )
        }
        .accessibilityLabel("Call \(entry.region) emergency at \(entry.number)")
    }
    
    // MARK: - Tips
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EMERGENCY TIPS")
                .font(.system(size: 11, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textSecondary)
            
            tipRow(icon: "location.fill", text: "Know your location — look for road signs, mile markers, or landmarks before calling.")
            tipRow(icon: "speaker.wave.3.fill", text: "Stay calm. Speak clearly. State your emergency, location, and number of people involved.")
            tipRow(icon: "phone.connection.fill", text: "Don't hang up. Let the operator end the call — they may need more information.")
        }
        .padding(.top, 8)
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(TacticalTheme.accent)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 13, design: .rounded).weight(.medium))
                .foregroundStyle(TacticalTheme.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TacticalTheme.cardBackground.opacity(0.6))
        )
    }
    
    // MARK: - Dial
    private func dialNumber(_ number: String) {
        guard let url = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(url)
    }
}
