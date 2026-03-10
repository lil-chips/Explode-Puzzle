import SpriteKit
import UIKit

final class BoardEffectsScene: SKScene {
    private let flashNode = SKSpriteNode(color: .white, size: .zero)

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0, y: 0)

        flashNode.alpha = 0
        flashNode.zPosition = 100
        addChild(flashNode)
    }

    func setCanvasSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        self.size = size
        flashNode.size = size
        flashNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    func flash(strength: CGFloat) {
        let s = max(0, min(1, strength))
        flashNode.removeAllActions()
        flashNode.alpha = 0
        let up = SKAction.fadeAlpha(to: 0.18 + 0.22 * s, duration: 0.05)
        let down = SKAction.fadeOut(withDuration: 0.10)
        flashNode.run(.sequence([up, down]))
    }

    func ring(at point: CGPoint, strength: CGFloat) {
        let s = max(0.4, min(2.0, strength))
        let node = SKShapeNode(circleOfRadius: 10)
        node.position = point
        node.strokeColor = UIColor.white.withAlphaComponent(0.55)
        node.lineWidth = 2.0
        node.fillColor = .clear
        node.zPosition = 50
        addChild(node)

        let scale = SKAction.scale(to: 3.2 * s, duration: 0.28)
        let fade = SKAction.fadeOut(withDuration: 0.28)
        node.run(.sequence([.group([scale, fade]), .removeFromParent()]))
    }

    func burst(at points: [CGPoint], colors: [UIColor], combo: Int) {
        guard !points.isEmpty else { return }

        // Overall intensity scales with combo (more combo = more particles).
        let base = 26
        let extra = min(140, combo * 22)
        let totalParticles = min(220, base + extra + points.count * 6)

        let perPoint = max(6, totalParticles / points.count)

        for (i, p) in points.enumerated() {
            let count = (i == 0) ? perPoint + (totalParticles % points.count) : perPoint
            spawnConfetti(at: p, count: count, palette: colors)
        }
    }

    private func spawnConfetti(at point: CGPoint, count: Int, palette: [UIColor]) {
        let palette = palette.isEmpty ? [UIColor.systemPink, .systemTeal, .systemYellow, .systemOrange, .systemPurple] : palette

        for _ in 0..<count {
            let w = CGFloat.random(in: 3...7)
            let h = CGFloat.random(in: 3...9)
            let node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 1.2)
            node.position = point
            node.zPosition = 40
            node.fillColor = palette.randomElement()!.withAlphaComponent(0.95)
            node.strokeColor = .clear
            node.zRotation = CGFloat.random(in: 0...(.pi * 2))

            let body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
            body.affectedByGravity = true
            body.allowsRotation = true
            body.linearDamping = 1.8
            body.angularDamping = 1.2
            body.restitution = 0.22
            body.friction = 0.2

            // Upward burst + sideways spread.
            let vx = CGFloat.random(in: -220...220)
            let vy = CGFloat.random(in: 180...520)
            body.velocity = CGVector(dx: vx, dy: vy)
            body.angularVelocity = CGFloat.random(in: -8...8)

            node.physicsBody = body
            addChild(node)

            let life = CGFloat.random(in: 0.55...1.05)
            let fade = SKAction.fadeOut(withDuration: TimeInterval(life))
            let shrink = SKAction.scale(to: CGFloat.random(in: 0.55...0.85), duration: TimeInterval(life))
            node.run(.sequence([.group([fade, shrink]), .removeFromParent()]))
        }
    }
}
