import SwiftUI

// MARK: - QuizView
// Interactive survival knowledge quiz. Questions are generated dynamically
// from SurvivalData — zero hardcoded quiz content.
// Features: timed questions, score tracking, streak rewards, review mode.
// Showcases dynamic content generation from existing data.

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quizState: QuizState = .ready
    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var selectedAnswer: String? = nil
    @State private var timeRemaining = 15
    @State private var timerActive = false
    @State private var showExplanation = false
    
    private let totalQuestions = 10
    
    enum QuizState { case ready, playing, reviewing, finished }
    
    var body: some View {
        ZStack {
            TacticalTheme.background.ignoresSafeArea()
            
            switch quizState {
            case .ready:    readyScreen
            case .playing:  questionScreen
            case .reviewing: reviewScreen
            case .finished: resultsScreen
            }
            
            ScanLinesOverlay().ignoresSafeArea()
        }
    }
    
    // MARK: - Ready Screen
    private var readyScreen: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(TacticalTheme.accent)
                .glow(TacticalTheme.accent, radius: 16)
            
            Text("SURVIVAL\nKNOWLEDGE TEST")
                .font(.system(size: 28, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Test your emergency response instincts.\n\(totalQuestions) questions • 15 seconds each")
                .font(.system(size: 15, design: .rounded).weight(.medium))
                .foregroundStyle(TacticalTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                HapticManager.shared.success()
                generateQuestions()
                withAnimation(.spring(response: 0.4)) { quizState = .playing }
                startTimer()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill").font(.system(size: 14, weight: .bold))
                    Text("START QUIZ").font(.system(size: 16, design: .monospaced).weight(.black))
                }
                .foregroundStyle(TacticalTheme.background)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(Capsule().fill(TacticalTheme.accent))
                .glow(TacticalTheme.accent, radius: 8)
            }
            
            Button { dismiss() } label: {
                Text("BACK").font(.system(size: 12, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Question Screen
    private var questionScreen: some View {
        VStack(spacing: 0) {
            questionHeader
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    questionCard.padding(.top, 16)
                    answerOptions
                    if showExplanation { explanationCard }
                }
                .padding(.horizontal, AdaptiveLayout.horizontalPadding)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var questionHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .padding(8)
                    .background(Circle().fill(TacticalTheme.cardBackground))
            }
            
            Spacer()
            
            // Progress
            HStack(spacing: 4) {
                ForEach(0..<totalQuestions, id: \.self) { i in
                    Circle()
                        .fill(i < currentIndex ? TacticalTheme.accent :
                              i == currentIndex ? TacticalTheme.accent.opacity(0.6) :
                              TacticalTheme.textSecondary.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
            
            Spacer()
            
            // Timer
            timerBadge
        }
        .padding(.horizontal, AdaptiveLayout.hudPadding)
        .padding(.vertical, 12)
    }
    
    private var timerBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill").font(.system(size: 11, weight: .bold))
            Text("\(timeRemaining)s")
                .font(.system(size: 13, design: .monospaced).weight(.black))
        }
        .foregroundStyle(timeRemaining <= 5 ? TacticalTheme.danger : TacticalTheme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(timeRemaining <= 5
                ? TacticalTheme.danger.opacity(0.15)
                : TacticalTheme.cardBackground)
        )
    }
    
    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Q\(currentIndex + 1)")
                    .font(.system(size: 13, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.accent)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 11))
                    Text("\(streak)").font(.system(size: 12, design: .monospaced).weight(.bold))
                }
                .foregroundStyle(streak > 0 ? Color(hex: "FF9500") : TacticalTheme.textSecondary.opacity(0.3))
            }
            
            if currentIndex < questions.count {
                Text(questions[currentIndex].question)
                    .font(.system(size: 18, design: .rounded).weight(.bold))
                    .foregroundStyle(TacticalTheme.textPrimary)
                    .lineSpacing(3)
                
                Text(questions[currentIndex].context)
                    .font(.system(size: 13, design: .rounded).weight(.medium))
                    .foregroundStyle(TacticalTheme.textSecondary)
                    .padding(.top, 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TacticalTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(TacticalTheme.accent.opacity(0.15), lineWidth: 1))
        )
    }
    
    private var answerOptions: some View {
        VStack(spacing: 10) {
            if currentIndex < questions.count {
                ForEach(questions[currentIndex].options, id: \.self) { option in
                    answerButton(option)
                }
            }
        }
    }
    
    private func answerButton(_ option: String) -> some View {
        let q = currentIndex < questions.count ? questions[currentIndex] : nil
        let isCorrect = option == q?.correctAnswer
        let isSelected = option == selectedAnswer
        let answered = selectedAnswer != nil
        
        return Button {
            guard !answered else { return }
            HapticManager.shared.tap()
            selectedAnswer = option
            timerActive = false
            
            if isCorrect {
                score += 1
                streak += 1
                bestStreak = max(bestStreak, streak)
                HapticManager.shared.success()
            } else {
                streak = 0
                HapticManager.shared.error()
            }
            
            showExplanation = true
            
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                advanceQuestion()
            }
        } label: {
            HStack(spacing: 12) {
                Text(option)
                    .font(.system(size: 14, design: .rounded).weight(.semibold))
                    .foregroundStyle(answerTextColor(isSelected: isSelected, isCorrect: isCorrect, answered: answered))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if answered && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18)).foregroundStyle(Color(hex: "4ADE80"))
                } else if answered && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18)).foregroundStyle(TacticalTheme.danger)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(answerBgColor(isSelected: isSelected, isCorrect: isCorrect, answered: answered))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(answerBorderColor(isSelected: isSelected, isCorrect: isCorrect, answered: answered), lineWidth: 1))
            )
        }
        .disabled(answered)
    }
    
    private func answerTextColor(isSelected: Bool, isCorrect: Bool, answered: Bool) -> Color {
        if !answered { return TacticalTheme.textPrimary }
        if isCorrect { return Color(hex: "4ADE80") }
        if isSelected { return TacticalTheme.danger }
        return TacticalTheme.textSecondary.opacity(0.5)
    }
    
    private func answerBgColor(isSelected: Bool, isCorrect: Bool, answered: Bool) -> Color {
        if !answered { return TacticalTheme.cardBackground }
        if isCorrect { return Color(hex: "4ADE80").opacity(0.08) }
        if isSelected { return TacticalTheme.danger.opacity(0.08) }
        return TacticalTheme.cardBackground.opacity(0.4)
    }
    
    private func answerBorderColor(isSelected: Bool, isCorrect: Bool, answered: Bool) -> Color {
        if !answered { return TacticalTheme.textSecondary.opacity(0.15) }
        if isCorrect { return Color(hex: "4ADE80").opacity(0.4) }
        if isSelected { return TacticalTheme.danger.opacity(0.4) }
        return Color.clear
    }
    
    private var explanationCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(TacticalTheme.accent)
            
            if currentIndex < questions.count {
                Text("From: \(questions[currentIndex].sourceTitle)")
                    .font(.system(size: 12, design: .rounded).weight(.medium))
                    .foregroundStyle(TacticalTheme.textSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(TacticalTheme.accent.opacity(0.06))
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Results Screen
    private var resultsScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            resultsBadge
            
            Text(resultTitle)
                .font(.system(size: 26, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("\(score) / \(totalQuestions) correct")
                .font(.system(size: 18, design: .rounded).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
            
            resultsStats
            
            Spacer()
            
            Button {
                HapticManager.shared.success()
                resetQuiz()
            } label: {
                Text("TRY AGAIN")
                    .font(.system(size: 14, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.background)
                    .padding(.horizontal, 36).padding(.vertical, 16)
                    .background(Capsule().fill(TacticalTheme.accent))
                    .glow(TacticalTheme.accent, radius: 8)
            }
            
            Button { dismiss() } label: {
                Text("DONE").font(.system(size: 12, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
    }
    
    private var resultsBadge: some View {
        ZStack {
            Circle()
                .fill(resultColor.opacity(0.1))
                .frame(width: 120, height: 120)
            
            Image(systemName: resultIcon)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(resultColor)
                .glow(resultColor, radius: 14)
        }
    }
    
    private var resultsStats: some View {
        HStack(spacing: 24) {
            statBubble(label: "ACCURACY", value: "\(score * 100 / max(totalQuestions, 1))%")
            statBubble(label: "BEST STREAK", value: "\(bestStreak)")
        }
    }
    
    private func statBubble(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.accent)
            Text(label)
                .font(.system(size: 9, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TacticalTheme.cardBackground)
        )
    }
    
    // Review placeholder
    private var reviewScreen: some View { readyScreen }
    
    // MARK: - Computed
    private var resultTitle: String {
        let pct = Double(score) / Double(totalQuestions)
        if pct >= 0.9 { return "SURVIVAL EXPERT!" }
        if pct >= 0.7 { return "WELL PREPARED" }
        if pct >= 0.5 { return "KEEP LEARNING" }
        return "STUDY UP!"
    }
    
    private var resultIcon: String {
        let pct = Double(score) / Double(totalQuestions)
        if pct >= 0.9 { return "star.fill" }
        if pct >= 0.7 { return "hand.thumbsup.fill" }
        if pct >= 0.5 { return "book.fill" }
        return "exclamationmark.triangle.fill"
    }
    
    private var resultColor: Color {
        let pct = Double(score) / Double(totalQuestions)
        if pct >= 0.9 { return TacticalTheme.accent }
        if pct >= 0.7 { return Color(hex: "4ADE80") }
        if pct >= 0.5 { return Color(hex: "5AC8FA") }
        return TacticalTheme.danger
    }
    
    // MARK: - Logic
    private func generateQuestions() {
        let allItems = SurvivalData.items(for: nil).filter { !$0.isLocked && $0.steps.count >= 3 }
        var generated: [QuizQuestion] = []
        let shuffled = allItems.shuffled()
        
        for item in shuffled.prefix(totalQuestions) {
            let correctStep = item.steps[0] // First step is usually the most critical
            
            // Get distractor steps from other items
            let distractors = allItems
                .filter { $0.id != item.id }
                .shuffled()
                .prefix(3)
                .map { $0.steps[0] }
            
            var options = [correctStep] + Array(distractors)
            options.shuffle()
            
            let q = QuizQuestion(
                question: "What should you do FIRST in: \(item.title)?",
                context: "Category: \(item.category.rawValue)",
                correctAnswer: correctStep,
                options: options,
                sourceTitle: item.title
            )
            generated.append(q)
        }
        
        questions = generated
    }
    
    private func startTimer() {
        timeRemaining = 15
        timerActive = true
        tickTimer()
    }
    
    private func tickTimer() {
        guard timerActive else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard timerActive else { return }
            timeRemaining -= 1
            if timeRemaining <= 0 {
                // Time's up — auto-wrong
                timerActive = false
                selectedAnswer = "__timeout__"
                streak = 0
                HapticManager.shared.error()
                showExplanation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { advanceQuestion() }
            } else {
                tickTimer()
            }
        }
    }
    
    private func advanceQuestion() {
        if currentIndex < totalQuestions - 1 {
            withAnimation(.spring(response: 0.35)) {
                currentIndex += 1
                selectedAnswer = nil
                showExplanation = false
            }
            startTimer()
        } else {
            withAnimation(.spring(response: 0.5)) {
                quizState = .finished
            }
        }
    }
    
    private func resetQuiz() {
        currentIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        selectedAnswer = nil
        showExplanation = false
        generateQuestions()
        withAnimation(.spring(response: 0.4)) { quizState = .playing }
        startTimer()
    }
}

// MARK: - QuizQuestion Model
struct QuizQuestion {
    let question: String
    let context: String
    let correctAnswer: String
    let options: [String]
    let sourceTitle: String
}
