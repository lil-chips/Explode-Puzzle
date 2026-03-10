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

    func burst(at points: [CGPoint], colors: [Color], combo: Int) {
        scene?.burst(at: points, colors: colors.map { UIColor($0) }, combo: combo)
    }

    func ring(at point: CGPoint, strength: CGFloat) {
        scene?.ring(at: point, strength: strength)
    }

    func flash(strength: CGFloat) {
        scene?.flash(strength: strength)
    }
}
