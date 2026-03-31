import Foundation
import SwiftUI
import SpriteKit
import Combine

@MainActor
final class BoardEffectsController: ObservableObject {
    fileprivate weak var scene: BoardEffectsScene?

    func attach(scene: BoardEffectsScene) {
        self.scene = scene
    }

    func setCanvasSize(_ size: CGSize) {
        scene?.setCanvasSize(size)
    }

    // ── Existing effects ───────────────────────────────────────────

    func burst(at points: [CGPoint], colors: [Color], combo: Int, linesCleared: Int) {
        scene?.burst(at: points,
                     colors: colors.map { UIColor($0) },
                     combo: combo,
                     linesCleared: linesCleared)
    }

    func glowWave(at point: CGPoint, strength: CGFloat) {
        scene?.glowWave(at: point, strength: strength)
    }

    func ring(at point: CGPoint, strength: CGFloat, thick: Bool = false) {
        scene?.ring(at: point, strength: strength, thick: thick)
    }

    func flash(strength: CGFloat) {
        scene?.flash(strength: strength)
    }

    // ── NEW: Score milestone full-screen celebration ───────────────
    /// Call when the player crosses a score milestone (1K / 5K / 10K / 50K / 100K …)
    func milestone(score: Int) {
        scene?.milestone(score: score)
    }

    // ── NEW: Danger pulse — board fill > 65% ──────────────────────
    /// fillRatio  0.0 … 1.0 (occupied cells / total cells)
    /// Pass 0 to stop pulsing.
    func dangerPulse(fillRatio: CGFloat) {
        scene?.dangerPulse(fillRatio: fillRatio)
    }

    // ── NEW: Power streak max celebration ─────────────────────────
    func streakMax(at center: CGPoint) {
        scene?.streakMax(at: center)
    }
}
