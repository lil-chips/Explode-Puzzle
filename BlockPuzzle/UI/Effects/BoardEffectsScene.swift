import SpriteKit
import UIKit

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

final class BoardEffectsScene: SKScene {
    private let flashNode = SKSpriteNode(color: .white, size: .zero)
    private static var _glowTex: SKTexture? = nil

    // SwiftUI/UIView coordinate space has origin at top-left (y down).
    // SpriteKit scene space has origin at bottom-left (y up).
    // Convert incoming points (from SwiftUI) into SpriteKit space.
    private func toSprite(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x, y: size.height - p.y)
    }

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
        // Brighter but slightly slower so the eye can "enjoy" the blast.
        let peak = 0.26 + 0.38 * s
        let up = SKAction.fadeAlpha(to: peak, duration: 0.06)
        let hold = SKAction.wait(forDuration: 0.05)
        let down = SKAction.fadeOut(withDuration: 0.22)
        flashNode.run(.sequence([up, hold, down]))
    }

    func ring(at point: CGPoint, strength: CGFloat, thick: Bool = false) {
        let s = max(0.4, min(2.2, strength))
        let node = SKShapeNode(circleOfRadius: 10)
        node.position = toSprite(point)
        node.strokeColor = UIColor.white.withAlphaComponent(0.62)
        node.lineWidth = thick ? 3.8 : 2.2
        node.fillColor = .clear
        node.zPosition = 60
        addChild(node)

        // Slightly slower so it reads as a "wave".
        let dur: TimeInterval = thick ? 0.52 : 0.44
        let scale = SKAction.scale(to: (thick ? 4.6 : 3.6) * s, duration: dur)
        scale.timingMode = .easeOut
        let fade = SKAction.fadeOut(withDuration: dur)
        node.run(.sequence([.group([scale, fade]), .removeFromParent()]))
    }

    func glowWave(at point: CGPoint, strength: CGFloat) {
        let s = max(0.4, min(2.2, strength))
        let tex = glowTexture()
        let sprite = SKSpriteNode(texture: tex)
        sprite.position = toSprite(point)
        sprite.zPosition = 55
        sprite.alpha = 0
        sprite.setScale(0.32)
        addChild(sprite)

        // Slower glow expansion for "enjoyable" explosion.
        let up = SKAction.fadeAlpha(to: 0.62, duration: 0.08)
        let expand = SKAction.scale(to: 1.55 * s, duration: 0.46)
        expand.timingMode = .easeOut
        let hold = SKAction.wait(forDuration: 0.06)
        let down = SKAction.fadeOut(withDuration: 0.36)
        sprite.run(.sequence([.group([up, expand]), hold, down, .removeFromParent()]))
    }

    func burst(at points: [CGPoint], colors: [UIColor], combo: Int, linesCleared: Int) {
        guard !points.isEmpty else { return }
        let spritePoints = points.map(toSprite)

        let lc = max(1, linesCleared)
        let multiLineBoost = (lc >= 2) ? 2.2 : 1.0

        // Combo should feel "超誇張" when high.
        // Use a gentle exponential curve after combo >= 4.
        let c = max(0, combo)
        let comboBoost: Double = {
            if c <= 1 { return 1.0 }
            if c <= 3 { return 1.0 + 0.35 * Double(c - 1) } // 1.0, 1.35, 1.70
            return 1.70 + pow(1.22, Double(c - 3)) * 0.95       // ramps fast
        }()

        // Overall intensity scales with combo + multi-line clears.
        let base = 36
        let extra = min(380, c * 44)
        var total = Double(base + extra + points.count * 8)
        total *= multiLineBoost
        total *= comboBoost

        // Tune overall particle count down a bit (requested -20%).
        total *= 0.80

        let capped = min(980.0, total)
        let perPoint = max(14, Int(capped) / spritePoints.count)
        let epicenter = average(spritePoints)

        for (i, p) in spritePoints.enumerated() {
            let count = (i == 0) ? perPoint + (Int(capped) % points.count) : perPoint
            spawnConfetti(at: p, count: count, palette: colors, comboBoost: comboBoost)
            // Add "block shards" that fly outwards from the cleared line.
            spawnShards(at: p, awayFrom: epicenter, palette: colors, boost: multiLineBoost * comboBoost)
        }
    }

    private func spawnConfetti(at point: CGPoint, count: Int, palette: [UIColor], comboBoost: Double) {
        // Brighter palette for "Explode" feel.
        let base = palette.isEmpty
            ? [UIColor.systemPink, .systemTeal, .systemYellow, .systemOrange, .systemPurple]
            : palette
        let brightPalette = base + [UIColor.white.withAlphaComponent(0.95), UIColor.cyan.withAlphaComponent(0.95)]

        for _ in 0..<count {
            // Make ribbons more likely when combo is high.
            let ribbonChance = min(0.55, 0.12 + 0.10 * comboBoost)
            let roll = Double.random(in: 0...1)

            let node: SKShapeNode
            if roll < ribbonChance {
                // Curved ribbon streamer (more "彩帶" feel)
                let len = CGFloat.random(in: 34...64)
                let amp = CGFloat.random(in: 6...16)
                let w = CGFloat.random(in: 2.6...4.2)
                node = SKShapeNode(path: ribbonPath(length: len, amplitude: amp, width: w))
            } else {
                let shape = Int.random(in: 0...2)
                switch shape {
                case 0:
                    // Confetti rectangle
                    let w = CGFloat.random(in: 3...8)
                    let h = CGFloat.random(in: 3...12)
                    node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 1.2)
                case 1:
                    // Dot
                    let r = CGFloat.random(in: 2.2...4.6)
                    node = SKShapeNode(circleOfRadius: r)
                default:
                    // Star (simple 5-point)
                    let r = CGFloat.random(in: 4...7.5)
                    node = SKShapeNode(path: starPath(radius: r, innerRadius: r * 0.45))
                }
            }

            node.position = point
            node.zPosition = 40
            node.fillColor = brightPalette.randomElement()!.withAlphaComponent(0.98)
            node.strokeColor = .clear
            node.zRotation = CGFloat.random(in: 0...(.pi * 2))

            addChild(node)

            // IMPORTANT: Keep the effect "above the cleared line" (no raining down).
            // We use action-based motion (no gravity) + enjoyable fade.
            let cb = CGFloat(min(3.0, comboBoost))
            let life = CGFloat.random(in: (0.70 - 0.06 * cb)...(1.15 - 0.08 * cb)).clamped(to: 0.45...1.25)

            // Explosive velocity with longer travel.
            let dx = CGFloat.random(in: (-150 - 55 * cb)...(150 + 55 * cb))
            let dy = CGFloat.random(in: (150 + 45 * cb)...(360 + 85 * cb))

            let drift = SKAction.moveBy(x: dx, y: dy, duration: TimeInterval(life))
            drift.timingMode = .easeOut

            // Ribbons should feel more like streamers: less spin.
            let spinRange: CGFloat = (roll < ribbonChance) ? 2.4 : (6.2 + 1.6 * cb)
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -spinRange...spinRange), duration: TimeInterval(life))

            // Fade should not disappear instantly; hold a bit then fade.
            let hold = SKAction.wait(forDuration: TimeInterval(0.10 + 0.05 * cb))
            let fade = SKAction.fadeOut(withDuration: TimeInterval(life * 0.75))
            let shrink = SKAction.scale(to: CGFloat.random(in: 0.58...0.92), duration: TimeInterval(life))

            node.run(.sequence([
                .group([drift, spin, shrink]),
                hold,
                fade,
                .removeFromParent()
            ]))
        }
    }

    private func spawnShards(at point: CGPoint, awayFrom epicenter: CGPoint, palette: [UIColor], boost: Double) {
        let basePalette = palette.isEmpty ? [UIColor.white] : palette

        // Direction away from epicenter (gives the "裂開炸開往外噴" feel).
        let dx = point.x - epicenter.x
        let dy = point.y - epicenter.y
        let len = max(0.001, sqrt(dx*dx + dy*dy))
        let ux = dx / len
        let uy = dy / len

        let b = max(1.0, min(4.0, boost))
        let rawShards = Double(5 + min(14, b * 4.0))
        let shards = max(3, Int(rawShards * 0.80))

        for _ in 0..<shards {
            let w = CGFloat.random(in: 1.8...3.2)
            let h = CGFloat.random(in: 1.8...3.2)
            let node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 0.9)
            node.position = point
            node.zPosition = 46
            node.fillColor = basePalette.randomElement()!.withAlphaComponent(0.98)
            node.strokeColor = .clear
            node.zRotation = CGFloat.random(in: 0...(.pi * 2))
            addChild(node)

            let life = CGFloat.random(in: 0.22...0.52)
            let speed = CGFloat.random(in: 140...360) * CGFloat(b)
            let side = CGFloat.random(in: -1.0...1.0) * 0.75
            let vx = (ux + side * (-uy)) * speed
            let vy = (uy + side * (ux)) * speed

            let drift = SKAction.moveBy(x: vx * life, y: vy * life, duration: TimeInterval(life))
            drift.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: TimeInterval(life))
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -9...9), duration: TimeInterval(life))
            let shrink = SKAction.scale(to: CGFloat.random(in: 0.5...0.85), duration: TimeInterval(life))
            node.run(.sequence([.group([drift, fade, spin, shrink]), .removeFromParent()]))
        }
    }

    private func average(_ points: [CGPoint]) -> CGPoint {
        var sx: CGFloat = 0
        var sy: CGFloat = 0
        for p in points { sx += p.x; sy += p.y }
        let n = CGFloat(points.count)
        return CGPoint(x: sx / n, y: sy / n)
    }

    private func glowTexture() -> SKTexture {
        if let t = Self._glowTex { return t }

        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor.clear.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))

            let center = CGPoint(x: size.width/2, y: size.height/2)
            let colors = [
                UIColor.white.withAlphaComponent(0.65).cgColor,
                UIColor.white.withAlphaComponent(0.28).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.35, 1.0]
            let space = CGColorSpaceCreateDeviceRGB()
            if let grad = CGGradient(colorsSpace: space, colors: colors, locations: locations) {
                cg.drawRadialGradient(
                    grad,
                    startCenter: center, startRadius: 0,
                    endCenter: center, endRadius: size.width/2,
                    options: .drawsAfterEndLocation
                )
            }
        }

        let tex = SKTexture(image: img)
        tex.filteringMode = .linear
        Self._glowTex = tex
        return tex
    }

    private func ribbonPath(length: CGFloat, amplitude: CGFloat, width: CGFloat) -> CGPath {
        // A simple curved ribbon made from a thick stroked Bezier path.
        // Build the centerline, then stroke it to get a filled ribbon shape.
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 0, y: -length / 2))
        p.addQuadCurve(
            to: CGPoint(x: 0, y: length / 2),
            controlPoint: CGPoint(x: amplitude, y: 0)
        )

        let stroked = p.cgPath.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 2)
        return stroked
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
