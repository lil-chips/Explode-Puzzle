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
        // Brighter palette for "Explode" feel.
        let base = palette.isEmpty
            ? [UIColor.systemPink, .systemTeal, .systemYellow, .systemOrange, .systemPurple]
            : palette
        let brightPalette = base + [UIColor.white.withAlphaComponent(0.95), UIColor.cyan.withAlphaComponent(0.95)]

        for _ in 0..<count {
            let shape = Int.random(in: 0...3)
            let node: SKShapeNode

            switch shape {
            case 0:
                // Confetti rectangle
                let w = CGFloat.random(in: 3...7)
                let h = CGFloat.random(in: 3...10)
                node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 1.2)
            case 1:
                // Dot
                let r = CGFloat.random(in: 2.2...4.2)
                node = SKShapeNode(circleOfRadius: r)
            case 2:
                // Star (simple 5-point)
                let r = CGFloat.random(in: 4...7)
                node = SKShapeNode(path: starPath(radius: r, innerRadius: r * 0.45))
            default:
                // Ribbon (thin long strip)
                let w = CGFloat.random(in: 2.2...3.6)
                let h = CGFloat.random(in: 10...18)
                node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 1.6)
            }

            node.position = point
            node.zPosition = 40
            node.fillColor = brightPalette.randomElement()!.withAlphaComponent(0.98)
            node.strokeColor = .clear
            node.zRotation = CGFloat.random(in: 0...(.pi * 2))

            addChild(node)

            // IMPORTANT: Keep the effect "above the cleared line" (no raining down).
            // We use action-based motion (no gravity) + fast fade.
            let life = CGFloat.random(in: 0.45...0.85)
            let dx = CGFloat.random(in: -90...90)
            let dy = CGFloat.random(in: 60...190)
            let drift = SKAction.moveBy(x: dx, y: dy, duration: TimeInterval(life))
            drift.timingMode = .easeOut

            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -3.5...3.5), duration: TimeInterval(life))
            let fade = SKAction.fadeOut(withDuration: TimeInterval(life))
            let shrink = SKAction.scale(to: CGFloat.random(in: 0.65...0.9), duration: TimeInterval(life))

            node.run(.sequence([
                .group([drift, spin, fade, shrink]),
                .removeFromParent()
            ]))
        }
    }

    private func starPath(radius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let points = 5
        let angle = CGFloat.pi * 2 / CGFloat(points * 2)
        let center = CGPoint(x: 0, y: 0)

        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? radius : innerRadius
            let a = angle * CGFloat(i) - CGFloat.pi / 2
            let p = CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.close()
        return path.cgPath
    }
}
