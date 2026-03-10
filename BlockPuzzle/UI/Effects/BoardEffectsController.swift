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

    func burst(at points: [CGPoint], colors: [Color], combo: Int, linesCleared: Int) {
        scene?.burst(at: points, colors: colors.map { UIColor($0) }, combo: combo, linesCleared: linesCleared)
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
}
