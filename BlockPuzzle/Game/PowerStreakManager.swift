import Foundation
import Combine

// MARK: - PowerStreakManager
// Tracks consecutive-clear streaks (each "slot-set" that clears at least 1 line).
// After every 2 consecutive clears, the score multiplier increases by ×0.5.
// The streak resets when the player places a piece without clearing any lines.
//
// Usage: inject into ContentView as @StateObject.

final class PowerStreakManager: ObservableObject {

    // ── Configuration ──────────────────────────────────────────────
    static let maxStreak    = 7          // dots on the indicator
    static let multPerPair  = 0.5        // +0.5× per 2 consecutive clears

    // ── Published state (drives SwiftUI) ──────────────────────────
    @Published private(set) var streak: Int = 0          // 0 … maxStreak
    @Published private(set) var multiplier: Double = 1.0 // 1.0, 1.5, 2.0, 2.5, 3.5, 4.0
    @Published private(set) var isMaxed: Bool = false

    // ── Internal ───────────────────────────────────────────────────
    private var pendingReward: Double = 0  // extra score to add after this turn

    // MARK: - API

    /// Call after every piece placement.
    /// - Parameter didClear: whether at least 1 row/col was cleared this turn.
    /// - Returns: current multiplier to apply to this turn's score.
    @discardableResult
    func register(didClear: Bool) -> Double {
        if didClear {
            streak     = min(streak + 1, Self.maxStreak)
        } else {
            streak     = 0
        }
        recalcMultiplier()
        return multiplier
    }

    /// Reset everything (new game).
    func reset() {
        streak      = 0
        multiplier  = 1.0
        isMaxed     = false
        pendingReward = 0
    }

    /// How many dots are visually "lit" (step i is lit when streak > i).
    func isLit(_ dot: Int) -> Bool {
        dot < streak
    }

    // MARK: - Private

    private func recalcMultiplier() {
        // +0.5 per every 2 consecutive clears, floored
        let pairs  = streak / 2
        multiplier = 1.0 + Double(pairs) * Self.multPerPair
        isMaxed    = (streak >= Self.maxStreak)
    }
}
