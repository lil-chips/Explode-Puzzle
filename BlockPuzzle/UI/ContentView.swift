import SwiftUI
import Combine
import UIKit

// MARK: - ContentView
// Main gameplay screen.
// Integrates: drag/drop, Audio, Haptics, PowerStreak,
//             danger visual, score milestones, SpriteKit effects.

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCoinsCenter: Bool = false

    let mode: GameMode
    let boardSize: BoardSize
    let fastTime: FastTimeLimit?

    // ── Game state ─────────────────────────────────────────────────
    @State private var gameState: GameState
    @State private var rng = SystemRandomNumberGenerator()

    init(mode: GameMode = .classic, boardSize: BoardSize = .eight,
         fastTime: FastTimeLimit? = nil) {
        self.mode      = mode
        self.boardSize = boardSize
        self.fastTime  = fastTime
        let limit = (mode == .fast ? (fastTime?.seconds ?? 0) : 0)
        _gameState          = State(initialValue: GameState(
            board: Board(width: boardSize.rawValue, height: boardSize.rawValue),
            currentPieces: [], score: 0))
        _remainingSeconds   = State(initialValue: limit)
        _fastTimeLimitSeconds = State(initialValue: limit)
        _fastStartDate      = State(initialValue: mode == .fast ? Date() : nil)
    }

    // ── Best score ─────────────────────────────────────────────────
    private var bestScore: Int {
        BestScoreStore.value(mode: mode, boardSize: boardSize)
    }

    // ── Board layout ───────────────────────────────────────────────
    @State private var boardFrame: CGRect = .zero
    @State private var gridRect:   CGRect = .zero

    // ── Effects ────────────────────────────────────────────────────
    @StateObject private var effects = BoardEffectsController()

    // ── Clear overlay animation ────────────────────────────────────
    @State private var clearOverlay:  [BlockPuzzlePoint: Int] = [:]
    @State private var clearFadeOut:  Bool = false
    @State private var boardShake:    CGFloat = 0

    // ── Drag state ─────────────────────────────────────────────────
    @State private var draggingPieceIndex: Int?    = nil
    @State private var dragLocation:       CGPoint? = nil

    // ── Coins (shared across all screens) ─────────────────────────
    @AppStorage("neonpuzzles.localCoins") private var localCoins: Int = 0

    // ── Skill drag state ───────────────────────────────────────────
    @State private var draggingSkillType: SkillType? = nil
    @State private var skillDragLocation: CGPoint?   = nil

    // ── Skill inventory (reactive AppStorage) ─────────────────────
    @AppStorage("neonpuzzles.skill.clearRow")   private var skillCountClearRow:   Int = 0
    @AppStorage("neonpuzzles.skill.clearCol")   private var skillCountClearCol:   Int = 0
    @AppStorage("neonpuzzles.skill.clearBoth")  private var skillCountClearBoth:  Int = 0
    @AppStorage("neonpuzzles.skill.clear3Rows") private var skillCountClear3Rows: Int = 0
    @AppStorage("neonpuzzles.skill.clear3Cols") private var skillCountClear3Cols: Int = 0
    @AppStorage("neonpuzzles.skill.blast3x3")   private var skillCountBlast3x3:   Int = 0

    // ── Fast mode ──────────────────────────────────────────────────
    @State private var remainingSeconds:    Int
    @State private var fastStartDate:       Date?
    @State private var fastTimeLimitSeconds: Int = 0
    @State private var combo:               Int = 0  // works in both modes
    @State private var scorePopupText:      String? = nil
    @State private var coinPopupText:       String? = nil

    // ── Game over ──────────────────────────────────────────────────
    @State private var showGameOver:     Bool   = false
    @State private var gameOverTitle:    String = "Game Over"
    @State private var finalComboAtEnd:  Int    = 0
    @State private var endEmptyCells:    Int    = 0
    @State private var endComboBonus:    Int    = 0
    @State private var endCleanBonus:    Int    = 0
    @State private var endTotalScore:    Int    = 0

    // ── NEW: Power Streak ──────────────────────────────────────────
    @StateObject private var powerStreak = PowerStreakManager()

    // ── NEW: Danger state ──────────────────────────────────────────
    @State private var dangerFill:   CGFloat = 0   // 0…1
    @State private var previousScore: Int    = 0   // for milestone detection

    // ── Fixed board size ───────────────────────────────────────────
    private var boardSide: CGFloat {
        max(280, min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 24)
    }

    // ── Colour palette ─────────────────────────────────────────────
    private let piecePalette = Theme.Neon.blockPalette
    private func pieceColor(for index: Int) -> Color {
        piecePalette[index % piecePalette.count]
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            NeonBackgroundView()
            mainStack
            scorePopup
            gameOverLayer
        }
        .sheet(isPresented: $showCoinsCenter) {
            NavigationStack { CoinsCenterView() }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            gameState.refillPiecesIfNeeded(random: &rng)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tickFastTimer()
        }
        .animation(.easeOut(duration: 0.25), value: showGameOver)
    }

    // Break out the main VStack so the type checker stays happy
    @ViewBuilder
    private var mainStack: some View {
        let s = powerStreak.streak
        let m = powerStreak.multiplier
        VStack(spacing: 8) {
            GameplayHUDView(
                mode:             mode,
                boardSize:        boardSize,
                bestScore:        bestScore,
                currentScore:     gameState.score,
                combo:            combo,
                remainingSeconds: remainingSeconds,
                streak:           s,
                multiplier:       m,
                onBack:           { dismiss() },
                onStore:          { showCoinsCenter = true }
            )
            .padding(.horizontal, 18)
            .padding(.top, 8)
            boardSection
                .frame(width: boardSide, height: boardSide)
            skillTray
            pieceTray
            newGameButton
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var gameOverLayer: some View {
        if showGameOver {
            makeEndScreen()
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
        }
    }

    private func makeEndScreen() -> EndScreenView {
        let adAction: (() -> Void)?
        if mode == .classic { adAction = watchAdContinue } else { adAction = nil }
        return EndScreenView(
            title:           gameOverTitle,
            mode:            mode,
            score:           gameState.score,
            bestScore:       bestScore,
            finalComboAtEnd: finalComboAtEnd,
            endEmptyCells:   endEmptyCells,
            endComboBonus:   endComboBonus,
            endCleanBonus:   endCleanBonus,
            endTotalScore:   endTotalScore,
            onRestart:       startNewGame,
            onWatchAd:       adAction,
            onHome:          { dismiss() }
        )
    }

    // MARK: - Sub-views

    private var boardSection: some View {
        BoardContainerView(
            gameState:         gameState,
            ghostCells:        ghost?.cells,
            ghostColor:        ghost?.color,
            ghostValid:        ghost?.valid ?? true,
            clearOverlay:      clearOverlay,
            clearFadeOut:      clearFadeOut,
            boardShake:        boardShake,
            skillPreviewCells: skillPreviewCells,
            skillPreviewColor: skillPreviewColor,
            effects:           effects,
            onGridRectChange:  { gridRect = $0 },
            onBoardFrameChange: { boardFrame = $0 }
        )
    }

    private var pieceTray: some View {
        PieceTrayView(
            pieces:        gameState.currentPieces,
            showGameOver:  showGameOver,
            colorForIndex: pieceColor,
            onDragChanged: { index, location in
                draggingPieceIndex = index
                dragLocation       = location
            },
            onDragEnded: { index in
                defer { draggingPieceIndex = nil; dragLocation = nil }
                guard let origin = ghostOrigin else { return }
                handleDrop(index: index, origin: origin)
            }
        )
    }

    // MARK: - Skill Tray

    private var skillTray: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                ForEach(SkillType.allCases) { skill in
                    skillTrayItem(skill)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SkillType.allCases) { skill in
                        skillTrayItem(skill)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
    }

    @ViewBuilder
    private func skillTrayItem(_ skill: SkillType) -> some View {
        let count = skillCount(skill)
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(count > 0
                            ? skill.color.opacity(0.15)
                            : Theme.Neon.panel)
                    gameplaySkillIconVisual(skill, enabled: count > 0)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 46, height: 38)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(count > 0
                            ? skill.color.opacity(0.55)
                            : Theme.Neon.panelStroke,
                            lineWidth: 1.2)
                )
                .shadow(color: count > 0
                    ? skill.color.opacity(0.35) : .clear,
                    radius: 6)
                Text(skill.shortTitle)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(count > 0
                        ? skill.color
                        : Theme.Neon.textMuted)
            }
            // Badge
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(skill.color))
                    .offset(x: 4, y: -4)
            } else {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.Neon.gold)
                    .offset(x: 4, y: -4)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if count == 0 { showCoinsCenter = true }
        }
        .gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .global)
                .onChanged { value in
                    guard skillCount(skill) > 0 else { return }
                    draggingSkillType = skill
                    skillDragLocation = value.location
                }
                .onEnded { _ in
                    defer {
                        draggingSkillType = nil
                        skillDragLocation = nil
                    }
                    guard skillCount(skill) > 0,
                          let target = skillTargetCell else { return }
                    handleSkillUse(skill: skill, target: target)
                }
        )
    }

    @ViewBuilder
    private func gameplaySkillIconVisual(_ skill: SkillType, enabled: Bool) -> some View {
        let c = enabled ? skill.color : skill.color.opacity(0.35)
        switch skill {
        case .clearRow:
            Rectangle().fill(c).frame(width: 24, height: 4).shadow(color: c.opacity(0.8), radius: enabled ? 5 : 0)
        case .clearCol:
            Rectangle().fill(c).frame(width: 4, height: 24).shadow(color: c.opacity(0.8), radius: enabled ? 5 : 0)
        case .clearBoth:
            ZStack {
                Rectangle().fill(enabled ? Theme.Neon.cyan : Theme.Neon.cyan.opacity(0.35)).frame(width: 4, height: 24)
                Rectangle().fill(enabled ? Theme.Neon.pink : Theme.Neon.pink.opacity(0.35)).frame(width: 24, height: 4)
                Circle().fill(Color.white.opacity(enabled ? 0.9 : 0.25)).frame(width: 6, height: 6)
            }
        case .clear3Rows:
            VStack(spacing: 3) {
                Rectangle().fill(c.opacity(0.5)).frame(width: 22, height: 2.5)
                Rectangle().fill(c).frame(width: 22, height: 4).shadow(color: c.opacity(0.9), radius: enabled ? 5 : 0)
                Rectangle().fill(c.opacity(0.5)).frame(width: 22, height: 2.5)
            }
        case .clear3Cols:
            HStack(spacing: 3) {
                Rectangle().fill(c.opacity(0.5)).frame(width: 2.5, height: 22)
                Rectangle().fill(c).frame(width: 4, height: 22).shadow(color: c.opacity(0.9), radius: enabled ? 5 : 0)
                Rectangle().fill(c.opacity(0.5)).frame(width: 2.5, height: 22)
            }
        case .blast3x3:
            VStack(spacing: 1.5) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 1.5) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .fill(c.opacity(0.75))
                                .frame(width: 7, height: 7)
                        }
                    }
                }
            }
            .shadow(color: c.opacity(0.80), radius: enabled ? 6 : 0)
        }
    }

    private var newGameButton: some View {
        Button { startNewGame() } label: {
            Text("NEW GAME")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .tracking(2)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Capsule(style: .continuous).fill(Theme.Neon.panelStrong))
                .overlay(Capsule(style: .continuous).stroke(Theme.Neon.panelStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.Neon.textPrimary)
        .padding(.top, 2)
    }

    @ViewBuilder
    private var scorePopup: some View {
        VStack(spacing: 0) {
            if let popup = scorePopupText {
                // Tech-style score burst: large glowing number + label row
                VStack(spacing: 4) {
                    let parts = popup.components(separatedBy: "  ")
                    Text(parts.first ?? popup)
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundStyle(combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan)
                        .shadow(color: (combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan).opacity(0.8), radius: 12)
                        .shadow(color: (combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan).opacity(0.4), radius: 24)
                    if parts.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(parts.dropFirst(), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .tracking(1.5)
                                    .foregroundStyle(combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill((combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan).opacity(0.15))
                                    )
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke((combo > 2 ? Theme.Neon.pink : Theme.Neon.cyan).opacity(0.35), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.top, 24)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.6).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: scorePopupText)
            }
            if let coins = coinPopupText {
                Text(coins)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Neon.gold)
                    .shadow(color: Theme.Neon.gold.opacity(0.6), radius: 8)
                    .padding(.top, scorePopupText == nil ? 24 : 6)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: coinPopupText)
            }
            Spacer()
        }
    }

    // MARK: - Game logic

    private func startNewGame() {
        showGameOver   = false
        gameOverTitle  = "Game Over"
        scorePopupText = nil
        coinPopupText  = nil
        combo          = 0
        finalComboAtEnd = 0
        endEmptyCells  = 0
        endComboBonus  = 0
        endCleanBonus  = 0
        endTotalScore  = 0
        previousScore  = 0

        powerStreak.reset()
        effects.dangerPulse(fillRatio: 0)

        if mode == .fast {
            fastTimeLimitSeconds = fastTime?.seconds ?? 60
            remainingSeconds     = fastTimeLimitSeconds
            fastStartDate        = Date()
        }

        gameState = GameState(
            board: Board(width: boardSize.rawValue, height: boardSize.rawValue),
            currentPieces: [], score: 0)
        gameState.refillPiecesIfNeeded(random: &rng)
    }

    private func updateBestScoreIfNeeded(_ score: Int) {
        if score > bestScore {
            BestScoreStore.set(score, mode: mode, boardSize: boardSize)
        }
    }

    // MARK: - Drop handler (core game loop)

    private func handleDrop(index: Int, origin: BlockPuzzlePoint) {
        guard let result = gameState.tryPlacePiece(
            at: index, origin: origin,
            colorIndex: index % piecePalette.count
        ) else { return }

        let linesCleared = result.rowsCleared + result.colsCleared
        let didClear     = linesCleared > 0

        // ── Audio ──────────────────────────────────────────────────
        AudioEngine.shared.sndPlace()
        if didClear { AudioEngine.shared.sndClear(linesCleared) }

        // ── Haptics ────────────────────────────────────────────────
        HapticEngine.shared.hapticPlace()
        if linesCleared >= 2 {
            HapticEngine.shared.hapticClearMulti(lines: linesCleared)
        } else if didClear {
            HapticEngine.shared.hapticClear()
        }

        // ── Power Streak ───────────────────────────────────────────
        let prevStreak = powerStreak.streak
        powerStreak.register(didClear: didClear)

        if didClear {
            AudioEngine.shared.sndStreak(step: powerStreak.streak)
            HapticEngine.shared.hapticStreak(step: powerStreak.streak)
            if powerStreak.isMaxed && prevStreak < PowerStreakManager.maxStreak {
                AudioEngine.shared.sndEvent()
                HapticEngine.shared.hapticStreakMax()
                if let centre = boardCenterInOverlay() {
                    effects.streakMax(at: centre)
                }
            }
        }

        // ── Apply streak multiplier to clear bonus ─────────────────
        if didClear {
            let bonus = Int(Double(result.clearBonus) * (powerStreak.multiplier - 1.0))
            if bonus > 0 { gameState.score += bonus }
        }

        // ── Combo tracking (Classic + Fast) ───────────────────────
        if didClear {
            combo += 1
            // Stacked combo score bonus (applies to both modes)
            let comboBonus = GameState.comboBonusScore(clearBonus: result.clearBonus, combo: combo)
            if comboBonus > 0 { gameState.score += comboBonus }

            // Coins: 3 per line × combo multiplier
            let coinsEarned = GameState.coinsForClear(lines: linesCleared, combo: combo)
            localCoins += coinsEarned

            // Score popup — tech-style large number
            let totalBonus = result.clearBonus + comboBonus
            var popParts: [String] = ["+\(totalBonus)"]
            if combo > 1 { popParts.append("×\(combo) COMBO") }
            if linesCleared >= 2 { popParts.append("\(linesCleared) LINES") }
            scorePopupText = popParts.joined(separator: "  ")
            coinPopupText  = "+\(coinsEarned) 🪙"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeOut(duration: 0.25)) {
                    scorePopupText = nil
                    coinPopupText  = nil
                }
            }

            // Fast mode: bonus time per clear
            if mode == .fast {
                remainingSeconds = min(fastTimeLimitSeconds, remainingSeconds + linesCleared * 3)
            }
        } else {
            combo = 0
        }

        // ── Visual clear effects ────────────────────────────────────
        if !result.clearedOverlay.isEmpty {
            clearOverlay = result.clearedOverlay
            clearFadeOut = false

            let flashStr = CGFloat(min(1.0, Double(linesCleared)*0.45 + Double(combo)*0.10))
            effects.flash(strength: flashStr)
            if let centre = boardCenterInOverlay() {
                effects.glowWave(at: centre,
                    strength: CGFloat(0.9 + 0.18*Double(combo) + 0.35*Double(max(0, linesCleared-1))))
                effects.ring(at: centre,
                    strength: CGFloat(0.9 + 0.25*Double(combo)),
                    thick: linesCleared >= 2)
            }
            let pts     = clearedCellCentersInOverlay(points: Array(result.clearedOverlay.keys))
            let palette = Theme.Neon.blockPalette
            let colors  = result.clearedOverlay.values.map { palette[$0 % palette.count] }
            effects.burst(at: pts, colors: Array(colors),
                          combo: combo, linesCleared: linesCleared)

            let shakeA: CGFloat = linesCleared >= 2 ? 16 : 10
            boardShake = shakeA
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08)  { boardShake = -shakeA * 0.6 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16)  { boardShake = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10)  { clearFadeOut = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35)  {
                clearOverlay = [:]
                clearFadeOut = false
            }
        }

        gameState.refillPiecesIfNeeded(random: &rng)
        updateBestScoreIfNeeded(gameState.score)

        // ── NEW: Danger visual ─────────────────────────────────────
        updateDangerState()

        // ── NEW: Score milestones ──────────────────────────────────
        checkMilestones()

        // ── Game over ──────────────────────────────────────────────
        if gameState.isGameOver() {
            triggerGameOver(title: "No Moves")
        }
    }

    // MARK: - ── NEW: Danger visual ──────────────────────────────────

    private func updateDangerState() {
        let total    = gameState.board.width * gameState.board.height
        let occupied = gameState.board.occupiedCells.count
        let ratio    = CGFloat(occupied) / CGFloat(total)

        if abs(ratio - dangerFill) > 0.02 {
            dangerFill = ratio
            effects.dangerPulse(fillRatio: ratio)
        }
    }

    // MARK: - ── NEW: Score milestones ────────────────────────────────

    private let milestones: [Int] = [1_000, 5_000, 10_000, 50_000,
                                      100_000, 200_000, 500_000]

    private func checkMilestones() {
        let old = previousScore
        let new = gameState.score
        for m in milestones {
            if old < m && new >= m {
                AudioEngine.shared.sndMilestone()
                HapticEngine.shared.hapticMilestone()
                effects.milestone(score: new)
                break
            }
        }
        previousScore = new
    }

    // MARK: - Game over

    private func triggerGameOver(title: String) {
        gameOverTitle   = title
        finalComboAtEnd = combo
        showGameOver    = true

        AudioEngine.shared.sndGameOver()
        HapticEngine.shared.hapticGameOver()
        effects.dangerPulse(fillRatio: 0)  // stop danger
    }

    // MARK: - Rewarded ad "continue" (classic only)

    private func watchAdContinue() {
        AdManager.shared.showRewarded(for: .continueGame) { rewarded in
            if rewarded {
                showGameOver = false
            }
        }
    }

    // MARK: - Fast mode timer

    private func tickFastTimer() {
        guard mode == .fast, !showGameOver,
              fastTimeLimitSeconds > 0,
              let start = fastStartDate else { return }
        let elapsed  = Int(Date().timeIntervalSince(start))
        remainingSeconds = max(0, fastTimeLimitSeconds - elapsed)
        if remainingSeconds <= 0 {
            let total  = boardSize.rawValue * boardSize.rawValue
            endEmptyCells = max(0, total - gameState.board.occupiedCells.count)
            endComboBonus = finalComboAtEnd * 200
            endCleanBonus = endEmptyCells * 2
            endTotalScore = gameState.score + endComboBonus + endCleanBonus
            updateBestScoreIfNeeded(endTotalScore)
            triggerGameOver(title: "Time Up")
        }
    }

    // MARK: - Skill inventory helpers

    private func skillCount(_ skill: SkillType) -> Int {
        switch skill {
        case .clearRow:   return skillCountClearRow
        case .clearCol:   return skillCountClearCol
        case .clearBoth:  return skillCountClearBoth
        case .clear3Rows: return skillCountClear3Rows
        case .clear3Cols: return skillCountClear3Cols
        case .blast3x3:   return skillCountBlast3x3
        }
    }

    private func decrementSkillCount(_ skill: SkillType) {
        switch skill {
        case .clearRow:   skillCountClearRow   = max(0, skillCountClearRow   - 1)
        case .clearCol:   skillCountClearCol   = max(0, skillCountClearCol   - 1)
        case .clearBoth:  skillCountClearBoth  = max(0, skillCountClearBoth  - 1)
        case .clear3Rows: skillCountClear3Rows = max(0, skillCountClear3Rows - 1)
        case .clear3Cols: skillCountClear3Cols = max(0, skillCountClear3Cols - 1)
        case .blast3x3:   skillCountBlast3x3   = max(0, skillCountBlast3x3   - 1)
        }
    }

    // MARK: - Skill drag computed properties

    private var skillTargetCell: BlockPuzzlePoint? {
        guard let loc = skillDragLocation, boardFrame != .zero else { return nil }
        let lx = loc.x - boardFrame.minX
        let ly = loc.y - boardFrame.minY
        guard lx >= 0, ly >= 0, lx <= boardFrame.width, ly <= boardFrame.height else { return nil }
        let gridSpacing: CGFloat = 2
        let side     = min(boardFrame.width, boardFrame.height)
        let cellSide = (side - gridSpacing * CGFloat(gameState.board.width - 1))
                       / CGFloat(gameState.board.width)
        let step     = cellSide + gridSpacing
        let cx = max(0, min(gameState.board.width  - 1, Int(floor(lx / step))))
        let cy = max(0, min(gameState.board.height - 1, Int(floor(ly / step))))
        return BlockPuzzlePoint(cx, cy)
    }

    private var skillPreviewCells: Set<BlockPuzzlePoint>? {
        guard let skill = draggingSkillType, let target = skillTargetCell else { return nil }
        return skill.previewCells(
            target: target,
            boardWidth:  gameState.board.width,
            boardHeight: gameState.board.height)
    }

    private var skillPreviewColor: Color? { draggingSkillType?.color }

    // MARK: - Skill use handler

    private func handleSkillUse(skill: SkillType, target: BlockPuzzlePoint) {
        guard skillCount(skill) > 0, !showGameOver else { return }
        decrementSkillCount(skill)

        let (removed, linesCleared, bonus) = gameState.applySkill(skill, at: target)

        // Audio + haptics
        AudioEngine.shared.sndClear(max(1, linesCleared))
        HapticEngine.shared.hapticClear()

        // Combo + coins for cleared lines
        if linesCleared > 0 {
            combo += 1
            let comboBonus = GameState.comboBonusScore(clearBonus: bonus, combo: combo)
            if comboBonus > 0 { gameState.score += comboBonus }
            let coinsEarned = GameState.coinsForClear(lines: linesCleared, combo: combo)
            localCoins += coinsEarned

            scorePopupText = "+\(bonus + comboBonus)  SKILL"
            coinPopupText  = "+\(coinsEarned) 🪙"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeOut(duration: 0.25)) {
                    scorePopupText = nil
                    coinPopupText  = nil
                }
            }
        }

        // VFX clear overlay
        if !removed.isEmpty {
            clearOverlay = removed
            clearFadeOut = false
            let flashStr = CGFloat(min(1.0, Double(removed.count) * 0.04 + 0.3))
            effects.flash(strength: flashStr)
            if let centre = boardCenterInOverlay() {
                effects.glowWave(at: centre, strength: 1.0)
                effects.ring(at: centre, strength: 1.0, thick: removed.count >= 8)
            }
            let pts     = clearedCellCentersInOverlay(points: Array(removed.keys))
            let palette = Theme.Neon.blockPalette
            let colors  = removed.values.map { palette[$0 % palette.count] }
            effects.burst(at: pts, colors: Array(colors),
                          combo: 0, linesCleared: max(1, linesCleared))
            let shakeA: CGFloat = 12
            boardShake = shakeA
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08)  { boardShake = -shakeA * 0.6 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16)  { boardShake = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10)  { clearFadeOut = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35)  {
                clearOverlay = [:]
                clearFadeOut = false
            }
        }

        gameState.refillPiecesIfNeeded(random: &rng)
        updateBestScoreIfNeeded(gameState.score)
        updateDangerState()
        if gameState.isGameOver() { triggerGameOver(title: "No Moves") }
    }

    // MARK: - Ghost piece

    private var ghostOrigin: BlockPuzzlePoint? {
        guard let loc = dragLocation, boardFrame != .zero else { return nil }
        let lx = loc.x - boardFrame.minX
        let ly = loc.y - boardFrame.minY
        if lx < 0 || ly < 0 || lx > boardFrame.width || ly > boardFrame.height {
            return nil
        }
        let gridSpacing: CGFloat = 2
        let side     = min(boardFrame.width, boardFrame.height)
        let cellSide = (side - gridSpacing * CGFloat(gameState.board.width - 1))
                       / CGFloat(gameState.board.width)
        let step     = cellSide + gridSpacing
        return BlockPuzzlePoint(Int(floor(lx / step)), Int(floor(ly / step)))
    }

    private var ghost: (cells: Set<BlockPuzzlePoint>, color: Color, valid: Bool)? {
        guard let idx = draggingPieceIndex,
              gameState.currentPieces.indices.contains(idx),
              let origin = ghostOrigin else { return nil }
        let piece = gameState.currentPieces[idx]
        let cells = Set(piece.cells.map {
            BlockPuzzlePoint(origin.x + $0.x, origin.y + $0.y)
        })
        return (cells, pieceColor(for: idx), gameState.board.canPlace(piece, at: origin))
    }

    // MARK: - Board overlay coordinate helpers

    private func boardCenterInOverlay() -> CGPoint? {
        guard gridRect != .zero else { return nil }
        let gridSpacing: CGFloat = 2
        let w        = gameState.board.width
        let side     = min(gridRect.width, gridRect.height)
        let cellSide = (side - gridSpacing * CGFloat(w - 1)) / CGFloat(w)
        let step     = cellSide + gridSpacing
        return CGPoint(x: gridRect.midX, y: gridRect.midY + step * 1.05)
    }

    private func clearedCellCentersInOverlay(
        points: [BlockPuzzlePoint]) -> [CGPoint] {
        guard gridRect != .zero else { return [] }
        let gridSpacing: CGFloat = 2
        let w        = gameState.board.width
        let side     = min(gridRect.width, gridRect.height)
        let cellSide = (side - gridSpacing * CGFloat(w - 1)) / CGFloat(w)
        let step     = cellSide + gridSpacing
        let yNudge   = step * 1.05
        return points.map { p in
            CGPoint(
                x: gridRect.minX + (CGFloat(p.x) + 0.5) * step,
                y: gridRect.minY + (CGFloat(p.y) + 0.5) * step + yNudge
            )
        }
    }
}

#Preview {
    ContentView()
}
