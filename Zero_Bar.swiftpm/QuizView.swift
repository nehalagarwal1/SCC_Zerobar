import SwiftUI

// MARK: - QuizView
// Interactive survival knowledge quiz with multiple question types.
// Questions are generated dynamically from SurvivalData — zero hardcoded quiz content.
// Features: category selection, varied question types, timed questions, score tracking,
// streak rewards, persistent stats, and rich results screen.

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
    @State private var selectedCategory: SurvivalCategory? = nil
    @State private var wrongAnswers: [QuizQuestion] = []
    
    // Persistent stats
    @AppStorage("quizBestScore") private var quizBestScore: Int = 0
    @AppStorage("quizBestStreak") private var quizBestStreak: Int = 0
    @AppStorage("quizAttempts") private var quizAttempts: Int = 0
    
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
        VStack(spacing: 0) {
            // Close button
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TacticalTheme.textSecondary)
                        .padding(8)
                        .background(Circle().fill(TacticalTheme.cardBackground))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 24)
                    
                    // Hero icon
                    ZStack {
                        Circle()
                            .fill(TacticalTheme.accent.opacity(0.1))
                            .frame(width: 110, height: 110)
                        
                        Circle()
                            .fill(TacticalTheme.accent.opacity(0.06))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundStyle(TacticalTheme.accent)
                            .glow(TacticalTheme.accent, radius: 16)
                    }
                    
                    Text("SURVIVAL\nKNOWLEDGE TEST")
                        .font(.system(size: 28, design: .monospaced).weight(.black))
                        .foregroundStyle(TacticalTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Test your emergency response instincts.\n\(totalQuestions) questions • 15 seconds each")
                        .font(.system(size: 15, design: .rounded).weight(.medium))
                        .foregroundStyle(TacticalTheme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // Past stats (if any)
                    if quizAttempts > 0 {
                        HStack(spacing: 16) {
                            statPill(icon: "star.fill", label: "BEST", value: "\(quizBestScore)/10", color: TacticalTheme.accent)
                            statPill(icon: "flame.fill", label: "STREAK", value: "\(quizBestStreak)", color: Color(hex: "FF9500"))
                            statPill(icon: "arrow.counterclockwise", label: "PLAYED", value: "\(quizAttempts)", color: Color(hex: "5E9EFF"))
                        }
                    }
                    
                    // Category Selection
                    VStack(spacing: 10) {
                        Text("CHOOSE CATEGORY")
                            .font(.system(size: 10, design: .monospaced).weight(.black))
                            .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                categoryChip(title: "All Topics", icon: "square.grid.2x2.fill", category: nil)
                                
                                ForEach(SurvivalCategory.allCases) { cat in
                                    categoryChip(title: cat.rawValue, icon: cat.iconName, category: cat)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // Start button
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
                    
                    Spacer().frame(height: 40)
                }
            }
        }
    }
    
    private func statPill(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 10, weight: .bold))
                Text(value).font(.system(size: 16, design: .monospaced).weight(.black))
            }
            .foregroundStyle(color)
            
            Text(label)
                .font(.system(size: 8, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(TacticalTheme.cardBackground)
        )
    }
    
    private func categoryChip(title: String, icon: String, category: SurvivalCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedCategory = category }
            HapticManager.shared.tap()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title.uppercased())
                    .font(.system(size: 10, design: .monospaced).weight(.bold))
            }
            .foregroundStyle(isSelected ? TacticalTheme.background : TacticalTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
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
        .buttonStyle(.plain)
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
            
            // Progress bar
            HStack(spacing: 3) {
                ForEach(0..<totalQuestions, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < currentIndex ? TacticalTheme.accent :
                              i == currentIndex ? TacticalTheme.accent.opacity(0.6) :
                              TacticalTheme.textSecondary.opacity(0.15))
                        .frame(height: 4)
                }
            }
            .frame(maxWidth: 160)
            
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
                // Question type badge
                Text(currentIndex < questions.count ? questions[currentIndex].typeBadge : "")
                    .font(.system(size: 9, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.background)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(TacticalTheme.accent))
                
                Text("Q\(currentIndex + 1) of \(totalQuestions)")
                    .font(.system(size: 11, design: .monospaced).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
                
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
                if let q = q { wrongAnswers.append(q) }
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                
                // Badge
                resultsBadge
                
                // Title
                Text(resultTitle)
                    .font(.system(size: 26, design: .monospaced).weight(.black))
                    .foregroundStyle(TacticalTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Score
                Text("\(score) / \(totalQuestions) correct")
                    .font(.system(size: 18, design: .rounded).weight(.bold))
                    .foregroundStyle(TacticalTheme.textSecondary)
                
                // Stats grid
                resultsStats
                
                // Accuracy bar
                accuracyBar
                
                // Review wrong answers
                if !wrongAnswers.isEmpty {
                    reviewWrongSection
                }
                
                Spacer().frame(height: 16)
                
                // Actions
                Button {
                    HapticManager.shared.success()
                    resetQuiz()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise").font(.system(size: 13, weight: .bold))
                        Text("PLAY AGAIN").font(.system(size: 14, design: .monospaced).weight(.black))
                    }
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
    }
    
    private var resultsBadge: some View {
        ZStack {
            Circle()
                .fill(resultColor.opacity(0.08))
                .frame(width: 130, height: 130)
            
            Circle()
                .fill(resultColor.opacity(0.05))
                .frame(width: 160, height: 160)
            
            VStack(spacing: 2) {
                Image(systemName: resultIcon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(resultColor)
                    .glow(resultColor, radius: 14)
                
                Text("\(score * 100 / max(totalQuestions, 1))%")
                    .font(.system(size: 20, design: .monospaced).weight(.black))
                    .foregroundStyle(resultColor)
            }
        }
    }
    
    private var resultsStats: some View {
        HStack(spacing: 12) {
            statBubble(label: "ACCURACY", value: "\(score * 100 / max(totalQuestions, 1))%", icon: "target")
            statBubble(label: "STREAK", value: "\(bestStreak)", icon: "flame.fill")
            statBubble(label: "TOTAL", value: "\(quizAttempts)", icon: "number")
        }
    }
    
    private func statBubble(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(TacticalTheme.accent.opacity(0.6))
            
            Text(value)
                .font(.system(size: 20, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.accent)
            Text(label)
                .font(.system(size: 8, design: .monospaced).weight(.bold))
                .foregroundStyle(TacticalTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(TacticalTheme.cardBackground)
        )
    }
    
    private var accuracyBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PERFORMANCE")
                .font(.system(size: 9, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.textSecondary.opacity(0.5))
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TacticalTheme.cardBackground)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [resultColor.opacity(0.8), resultColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(score) / CGFloat(max(totalQuestions, 1)))
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(TacticalTheme.cardBackground.opacity(0.5))
        )
    }
    
    private var reviewWrongSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REVIEW MISTAKES")
                .font(.system(size: 10, design: .monospaced).weight(.black))
                .foregroundStyle(TacticalTheme.danger.opacity(0.8))
            
            ForEach(Array(wrongAnswers.enumerated()), id: \.offset) { _, q in
                VStack(alignment: .leading, spacing: 6) {
                    Text(q.question)
                        .font(.system(size: 12, design: .rounded).weight(.bold))
                        .foregroundStyle(TacticalTheme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: "4ADE80"))
                        Text(q.correctAnswer)
                            .font(.system(size: 11, design: .rounded).weight(.medium))
                            .foregroundStyle(Color(hex: "4ADE80"))
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(TacticalTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(TacticalTheme.danger.opacity(0.15), lineWidth: 1)
                        )
                )
            }
        }
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
        let allItems = SurvivalData.items(for: selectedCategory).filter { !$0.isLocked && $0.steps.count >= 3 }
        let fallbackItems = SurvivalData.items(for: nil).filter { !$0.isLocked && $0.steps.count >= 3 }
        var generated: [QuizQuestion] = []
        let shuffled = allItems.shuffled()
        
        for (idx, item) in shuffled.prefix(totalQuestions).enumerated() {
            let questionType = idx % 3 // Rotate between question types
            
            switch questionType {
            case 0:
                // Type 1: "What's the FIRST step?" (original)
                let correctStep = item.steps[0]
                let distractors = fallbackItems
                    .filter { $0.id != item.id }
                    .shuffled()
                    .prefix(3)
                    .map { $0.steps[0] }
                var options = [correctStep] + Array(distractors)
                options.shuffle()
                
                generated.append(QuizQuestion(
                    question: "What should you do FIRST for: \(item.title)?",
                    context: "Category: \(item.category.rawValue)",
                    correctAnswer: correctStep,
                    options: options,
                    sourceTitle: item.title,
                    questionType: .firstStep
                ))
                
            case 1:
                // Type 2: "How many steps?" 
                let correctCount = item.steps.count
                let wrongCounts = [correctCount + 1, correctCount + 2, max(1, correctCount - 1)]
                var options = (["\(correctCount) steps"] + wrongCounts.map { "\($0) steps" })
                options.shuffle()
                
                generated.append(QuizQuestion(
                    question: "How many steps are in: \(item.title)?",
                    context: "Category: \(item.category.rawValue)",
                    correctAnswer: "\(correctCount) steps",
                    options: options,
                    sourceTitle: item.title,
                    questionType: .stepCount
                ))
                
            default:
                // Type 3: "Which category does this belong to?"
                let correctCat = item.category.rawValue
                let wrongCats = SurvivalCategory.allCases
                    .filter { $0 != item.category }
                    .shuffled()
                    .prefix(3)
                    .map { $0.rawValue }
                var options = [correctCat] + Array(wrongCats)
                options.shuffle()
                
                generated.append(QuizQuestion(
                    question: "Which category does \"\(item.title)\" belong to?",
                    context: "Identify the survival domain",
                    correctAnswer: correctCat,
                    options: options,
                    sourceTitle: item.title,
                    questionType: .category
                ))
            }
        }
        
        questions = generated
        wrongAnswers = []
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
                if currentIndex < questions.count {
                    wrongAnswers.append(questions[currentIndex])
                }
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
            // Save stats
            quizAttempts += 1
            quizBestScore = max(quizBestScore, score)
            quizBestStreak = max(quizBestStreak, bestStreak)
            
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
        wrongAnswers = []
        generateQuestions()
        withAnimation(.spring(response: 0.4)) { quizState = .playing }
        startTimer()
    }
}

// MARK: - QuizQuestion Model
enum QuestionType {
    case firstStep
    case stepCount
    case category
}

struct QuizQuestion {
    let question: String
    let context: String
    let correctAnswer: String
    let options: [String]
    let sourceTitle: String
    let questionType: QuestionType
    
    var typeBadge: String {
        switch questionType {
        case .firstStep: return "FIRST STEP"
        case .stepCount: return "STEP COUNT"
        case .category:  return "CATEGORY"
        }
    }
}
