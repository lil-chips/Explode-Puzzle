import SpriteKit
import UIKit

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - BoardEffectsScene
// Tech / electric-arc / ignite VFX — no confetti ribbons.
// All public API preserved; only private spawn helpers rewritten.

final class BoardEffectsScene: SKScene {

    // ── Persistent nodes ──────────────────────────────────────────
    private let flashNode   = SKSpriteNode(color: .white, size: .zero)
    private let dangerFrame = SKShapeNode()
    private var dangerTimer: Timer?
    private var dangerPhase: CGFloat = 0
    private static var _glowTex: SKTexture? = nil

    // SwiftUI → SpriteKit coordinate flip
    private func toSprite(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x, y: size.height - p.y)
    }

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint     = CGPoint(x: 0, y: 0)

        flashNode.alpha     = 0
        flashNode.zPosition = 100
        addChild(flashNode)

        dangerFrame.lineWidth   = 0
        dangerFrame.fillColor   = .clear
        dangerFrame.strokeColor = UIColor(red: 1, green: 0.22, blue: 0.22, alpha: 1)
        dangerFrame.zPosition   = 90
        dangerFrame.alpha       = 0
        addChild(dangerFrame)
    }

    func setCanvasSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        self.size = size
        flashNode.size     = size
        flashNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        updateDangerFrameShape()
    }

    // MARK: - ══ Flash ══

    func flash(strength: CGFloat) {
        let s = max(0, min(1, strength))
        flashNode.removeAllActions()
        flashNode.alpha = 0
        // Neon-cyan tint for tech feel
        flashNode.color = UIColor(red: 0.1, green: 0.9, blue: 1.0, alpha: 1)
        let peak = 0.18 + 0.28 * s
        let up   = SKAction.fadeAlpha(to: peak, duration: 0.05)
        let hold = SKAction.wait(forDuration: 0.04)
        let down = SKAction.fadeOut(withDuration: 0.20)
        flashNode.run(.sequence([up, hold, down]))
    }

    // MARK: - ══ Ring ══ (neon coloured)

    func ring(at point: CGPoint, strength: CGFloat, thick: Bool = false) {
        let s    = max(0.4, min(2.2, strength))
        let sp   = toSprite(point)
        let colors: [UIColor] = [
            UIColor(red: 0, green: 0.89, blue: 1, alpha: 0.75),
            UIColor(red: 1, green: 0.42, blue: 0.61, alpha: 0.65),
            UIColor(red: 0.7, green: 0.42, blue: 1, alpha: 0.65)
        ]
        let ringCount = thick ? 3 : 2
        for i in 0..<ringCount {
            let delay = Double(i) * 0.06
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                let node = SKShapeNode(circleOfRadius: 8 + CGFloat(i) * 4)
                node.position    = sp
                node.strokeColor = colors[i % colors.count]
                node.lineWidth   = thick ? 2.8 : 1.8
                node.fillColor   = .clear
                node.zPosition   = 60
                self.addChild(node)
                let dur: TimeInterval = thick ? 0.50 : 0.40
                let scale = SKAction.scale(to: (thick ? 4.2 : 3.2) * s, duration: dur)
                scale.timingMode = .easeOut
                let fade  = SKAction.fadeOut(withDuration: dur)
                node.run(.sequence([.group([scale, fade]), .removeFromParent()]))
            }
        }
    }

    // MARK: - ══ Glow wave ══

    func glowWave(at point: CGPoint, strength: CGFloat) {
        let s      = max(0.4, min(2.2, strength))
        let tex    = glowTexture()
        let sprite = SKSpriteNode(texture: tex)
        sprite.position  = toSprite(point)
        sprite.zPosition = 55
        sprite.alpha     = 0
        sprite.color     = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        sprite.colorBlendFactor = 0.55
        sprite.setScale(0.28)
        addChild(sprite)

        let up   = SKAction.fadeAlpha(to: 0.55, duration: 0.07)
        let exp  = SKAction.scale(to: 1.45 * s, duration: 0.42)
        exp.timingMode = .easeOut
        let hold = SKAction.wait(forDuration: 0.05)
        let down = SKAction.fadeOut(withDuration: 0.32)
        sprite.run(.sequence([.group([up, exp]), hold, down, .removeFromParent()]))
    }

    // MARK: - ══ Burst (main per-clear effect) ══
    // Replaced confetti with electric ignite particles + arc bolts.

    func burst(at points: [CGPoint], colors: [UIColor], combo: Int, linesCleared: Int) {
        guard !points.isEmpty else { return }
        let spritePoints = points.map(toSprite)

        let lc             = max(1, linesCleared)
        let multiLineBoost = (lc >= 2) ? 2.0 : 1.0
        let c              = max(0, combo)
        let comboBoost: Double = {
            if c <= 1 { return 1.0 }
            if c <= 3 { return 1.0 + 0.30 * Double(c - 1) }
            return 1.60 + pow(1.18, Double(c - 3)) * 0.9
        }()

        let base     = 20
        let extra    = min(200, c * 30)
        var total    = Double(base + extra + points.count * 5)
        total       *= multiLineBoost * comboBoost * 0.55
        let capped   = min(600.0, total)
        let perPoint = max(8, Int(capped) / spritePoints.count)
        let epicenter = average(spritePoints)

        for (i, p) in spritePoints.enumerated() {
            let count = (i == 0) ? perPoint + (Int(capped) % spritePoints.count) : perPoint
            let col   = colors.isEmpty ? UIColor.cyan : colors[i % colors.count]
            spawnIgniteParticles(at: p, count: count, color: col, comboBoost: comboBoost)
            spawnArcBolts(at: p, awayFrom: epicenter, color: col,
                          boost: multiLineBoost * comboBoost)
        }

        // For multi-line clears: add electric shockwave lines from epicenter
        if lc >= 2 {
            spawnShockwaveLines(at: epicenter, count: 6 + lc * 2,
                                boost: multiLineBoost * comboBoost)
        }
    }

    // MARK: - ══ Danger pulse ══

    func dangerPulse(fillRatio: CGFloat) {
        dangerTimer?.invalidate()
        dangerTimer = nil

        if fillRatio < 0.62 {
            dangerFrame.run(.fadeOut(withDuration: 0.4))
            return
        }
        updateDangerFrameShape()

        let interval = fillRatio > 0.82 ? 0.36 : 0.60
        let maxAlpha = fillRatio > 0.82 ? CGFloat(0.82) : CGFloat(0.50)
        let lineW    = fillRatio > 0.82 ? CGFloat(3.2)  : CGFloat(2.0)
        dangerFrame.lineWidth = lineW

        dangerTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.dangerFrame.removeAllActions()
                let fadeIn  = SKAction.fadeAlpha(to: maxAlpha, duration: interval * 0.38)
                let fadeOut = SKAction.fadeAlpha(to: 0.04, duration: interval * 0.62)
                self.dangerFrame.run(.sequence([fadeIn, fadeOut]))
            }
        }
        dangerTimer?.fire()
    }

    private func updateDangerFrameShape() {
        guard size.width > 0 else { return }
        let inset: CGFloat = 4
        let rect = CGRect(x: inset, y: inset,
                          width: size.width - inset * 2,
                          height: size.height - inset * 2)
        dangerFrame.path = UIBezierPath(roundedRect: rect, cornerRadius: 14).cgPath
    }

    // MARK: - ══ Score milestone ══ (tech celebration)

    func milestone(score: Int) {
        // Bright cyan flash
        flashNode.removeAllActions()
        flashNode.alpha = 0
        flashNode.color = UIColor(red: 0, green: 0.9, blue: 1.0, alpha: 1)
        flashNode.colorBlendFactor = 0.8
        flashNode.run(.sequence([
            .fadeAlpha(to: 0.50, duration: 0.04),
            .wait(forDuration: 0.04),
            .fadeOut(withDuration: 0.32)
        ]))

        let centre = CGPoint(x: size.width / 2, y: size.height / 2)

        // Neon-coloured ring burst
        let ringColors: [UIColor] = [
            UIColor(red: 0, green: 0.89, blue: 1,    alpha: 0.9),
            UIColor(red: 1, green: 0.42, blue: 0.61, alpha: 0.9),
            UIColor(red: 0.7, green: 0.42, blue: 1,  alpha: 0.9),
            UIColor(red: 1, green: 0.62, blue: 0.29, alpha: 0.9)
        ]
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.055) { [weak self] in
                guard let self else { return }
                let r = SKShapeNode(circleOfRadius: 10)
                r.position    = centre
                r.strokeColor = ringColors[i % ringColors.count]
                r.fillColor   = .clear
                r.lineWidth   = 2.2
                r.zPosition   = 70
                self.addChild(r)
                let scale = SKAction.scale(to: 7.0 + CGFloat(i) * 1.0, duration: 0.58)
                scale.timingMode = .easeOut
                let fade  = SKAction.fadeOut(withDuration: 0.58)
                r.run(.sequence([.group([scale, fade]), .removeFromParent()]))
            }
        }

        // Dense electric particle burst from centre
        let palette: [UIColor] = [
            UIColor(red: 0, green: 0.89, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.42, blue: 0.61, alpha: 1),
            UIColor(red: 0.69, green: 0.42, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0.62, blue: 0.29, alpha: 1),
            UIColor.white
        ]
        for col in palette {
            spawnIgniteParticles(at: centre, count: 40, color: col, comboBoost: 3.0)
        }
        spawnShockwaveLines(at: centre, count: 24, boost: 4.0)

        // Floating milestone label
        let label = labelText(for: score)
        if !label.isEmpty { spawnMilestoneLabel(label, at: centre) }
    }

    private func labelText(for score: Int) -> String {
        switch score {
        case 1_000..<5_000:     return "1K !"
        case 5_000..<10_000:    return "5K !"
        case 10_000..<50_000:   return "10K !"
        case 50_000..<100_000:  return "50K !!"
        case 100_000..<200_000: return "100K !!"
        case 200_000..<500_000: return "200K !!!"
        case 500_000...:        return "500K !!!"
        default:                return ""
        }
    }

    private func spawnMilestoneLabel(_ text: String, at point: CGPoint) {
        let label = SKLabelNode(text: text)
        label.fontName  = "AvenirNext-Heavy"
        label.fontSize  = 54
        label.fontColor = UIColor(red: 0, green: 0.95, blue: 1, alpha: 1)
        label.position  = CGPoint(x: point.x, y: point.y - 40)
        label.zPosition = 80
        label.alpha     = 0
        label.setScale(0.3)
        // Glow shadow via second label
        let shadow = SKLabelNode(text: text)
        shadow.fontName  = label.fontName
        shadow.fontSize  = label.fontSize
        shadow.fontColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 0.45)
        shadow.position  = .zero
        shadow.zPosition = -1
        shadow.setScale(1.06)
        label.addChild(shadow)
        addChild(label)

        let appear = SKAction.group([
            .fadeIn(withDuration: 0.12),
            .scale(to: 1.08, duration: 0.12)
        ])
        let settle = SKAction.scale(to: 1.0, duration: 0.07)
        let rise   = SKAction.moveBy(x: 0, y: 80, duration: 0.95)
        rise.timingMode = .easeOut
        let fade = SKAction.sequence([.wait(forDuration: 0.45), .fadeOut(withDuration: 0.45)])
        label.run(.sequence([appear, settle, .group([rise, fade]), .removeFromParent()]))
    }

    // MARK: - ══ Streak max ══ (orange electric arcs)

    func streakMax(at center: CGPoint) {
        let sp = toSprite(center)
        let orange = UIColor(red: 1, green: 0.62, blue: 0.10, alpha: 1)
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.045) { [weak self] in
                guard let self else { return }
                let r = SKShapeNode(circleOfRadius: 6)
                r.position    = sp
                r.strokeColor = orange.withAlphaComponent(0.9)
                r.fillColor   = .clear
                r.lineWidth   = 2.5
                r.zPosition   = 65
                self.addChild(r)
                let s = SKAction.scale(to: 4.5 + CGFloat(i) * 0.7, duration: 0.36)
                s.timingMode = .easeOut
                r.run(.sequence([.group([s, .fadeOut(withDuration: 0.36)]),
                                 .removeFromParent()]))
            }
        }
        spawnIgniteParticles(at: sp, count: 70, color: orange, comboBoost: 2.0)
        spawnShockwaveLines(at: sp, count: 12, boost: 2.5)
    }

    // MARK: - Private: Electric ignite particles
    // Small bright squares / diamonds / hexagons that radiate outward — tech feel.

    private func spawnIgniteParticles(at point: CGPoint, count: Int,
                                      color: UIColor, comboBoost: Double) {
        let cb   = CGFloat(min(3.5, comboBoost))
        let bright: [UIColor] = [
            color,
            color.withAlphaComponent(0.85),
            UIColor.white.withAlphaComponent(0.95),
            UIColor.white.withAlphaComponent(0.70)
        ]

        for i in 0..<count {
            let node: SKShapeNode
            let roll = i % 4
            switch roll {
            case 0: // small square
                let s = CGFloat.random(in: 1.8...3.8)
                node = SKShapeNode(rectOf: CGSize(width: s, height: s), cornerRadius: 0.5)
            case 1: // diamond (rotated square)
                let s = CGFloat.random(in: 2.2...4.2)
                node = SKShapeNode(rectOf: CGSize(width: s, height: s), cornerRadius: 0.3)
                node.zRotation = .pi / 4
            case 2: // small circle spark
                node = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.2...2.8))
            default: // thin elongated shard (lightning fragment)
                let w = CGFloat.random(in: 1.0...1.8)
                let h = CGFloat.random(in: 5.0...12.0)
                node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 0.4)
            }

            node.position    = point
            node.zPosition   = 42
            node.fillColor   = bright.randomElement()!
            node.strokeColor = .clear
            node.zRotation   = CGFloat.random(in: 0...(.pi * 2))
            addChild(node)

            let life = CGFloat.random(in: 0.30...0.75).clamped(to: 0.25...0.85)
            // Particles shoot outward in all directions (ignite explosion pattern)
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: (80 + 40*cb)...(220 + 80*cb))
            let dx    = cos(angle) * speed * life
            let dy    = sin(angle) * speed * life

            let drift = SKAction.moveBy(x: dx, y: dy, duration: TimeInterval(life))
            drift.timingMode = .easeOut
            let spin  = SKAction.rotate(byAngle: CGFloat.random(in: -5...5),
                                        duration: TimeInterval(life))
            let shrink = SKAction.scale(to: CGFloat.random(in: 0.1...0.4),
                                        duration: TimeInterval(life))
            let fadeDelay = life * 0.30
            let fade = SKAction.sequence([
                .wait(forDuration: TimeInterval(fadeDelay)),
                .fadeOut(withDuration: TimeInterval(life * 0.70))
            ])
            node.run(.sequence([
                .group([drift, spin, shrink, fade]),
                .removeFromParent()
            ]))
        }
    }

    // MARK: - Private: Arc bolts (lightning segments)
    // Zigzag lines shooting outward from cleared cell centres.

    private func spawnArcBolts(at point: CGPoint, awayFrom epicenter: CGPoint,
                                color: UIColor, boost: Double) {
        let b      = max(1.0, min(4.5, boost))
        let boltCount = max(2, Int(3.0 * b * 0.5))

        let dx  = point.x - epicenter.x
        let dy  = point.y - epicenter.y
        let len = max(0.001, sqrt(dx*dx + dy*dy))
        let ux  = dx / len; let uy = dy / len

        for _ in 0..<boltCount {
            let boltLen    = CGFloat.random(in: 35...120) * CGFloat(b * 0.55)
            let segCount   = Int.random(in: 4...8)
            let spread     = CGFloat.random(in: -1.0...1.0)
            // Direction: away from epicenter with some spread
            let angle      = atan2(uy + spread * (-ux) * 0.6, ux + spread * uy * 0.6)

            let path       = lightningPath(from: .zero,
                                           angle: angle,
                                           length: boltLen,
                                           segments: segCount,
                                           jitter: boltLen * 0.22)
            let node       = SKShapeNode(path: path)
            node.position  = point
            node.zPosition = 50
            node.strokeColor = color.withAlphaComponent(0.95)
            node.lineWidth = CGFloat.random(in: 1.0...2.2)
            node.fillColor = .clear
            node.lineCap   = .round
            node.lineJoin  = .round
            addChild(node)

            let life: TimeInterval = Double.random(in: 0.12...0.28)
            let fadeIn  = SKAction.fadeAlpha(to: 1.0, duration: 0.03)
            let hold    = SKAction.wait(forDuration: life * 0.25)
            let fadeOut = SKAction.fadeOut(withDuration: life * 0.75)
            // Add a subtle scale-out
            let scaleOut = SKAction.scale(to: 0.6, duration: life)
            node.run(.sequence([fadeIn, hold, .group([fadeOut, scaleOut]), .removeFromParent()]))
        }
    }

    // MARK: - Private: Shockwave lines (multi-line clear bonus)
    // Straight lines radiating from a central point, like an energy explosion.

    private func spawnShockwaveLines(at point: CGPoint, count: Int, boost: Double) {
        let b      = max(1.0, min(5.0, boost))
        let colors: [UIColor] = [
            UIColor(red: 0, green: 0.89, blue: 1, alpha: 0.9),
            UIColor(red: 1, green: 0.42, blue: 0.61, alpha: 0.9),
            UIColor.white.withAlphaComponent(0.9),
            UIColor(red: 0.69, green: 0.42, blue: 1, alpha: 0.9)
        ]

        for i in 0..<count {
            let angle   = CGFloat(i) / CGFloat(count) * .pi * 2
            let length  = CGFloat.random(in: 40...120) * CGFloat(b * 0.55)
            let jitter  = length * CGFloat.random(in: 0.05...0.18)

            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            // Small mid-point jitter for electric feel
            let midX = cos(angle) * length * 0.5 + CGFloat.random(in: -jitter...jitter)
            let midY = sin(angle) * length * 0.5 + CGFloat.random(in: -jitter...jitter)
            let endX = cos(angle) * length
            let endY = sin(angle) * length
            path.addLine(to: CGPoint(x: midX, y: midY))
            path.addLine(to: CGPoint(x: endX, y: endY))

            let node = SKShapeNode(path: path.cgPath)
            node.position    = point
            node.zPosition   = 48
            node.strokeColor = colors[i % colors.count]
            node.lineWidth   = CGFloat.random(in: 0.8...1.8)
            node.fillColor   = .clear
            node.lineCap     = .round
            addChild(node)

            let life: TimeInterval = Double.random(in: 0.18...0.38)
            let fade = SKAction.fadeOut(withDuration: life)
            let grow = SKAction.scale(to: 1.0 + CGFloat.random(in: 0.1...0.4), duration: life * 0.4)
            node.run(.sequence([.group([fade, grow]), .removeFromParent()]))
        }
    }

    // MARK: - Private: Lightning path builder

    private func lightningPath(from start: CGPoint, angle: CGFloat,
                                length: CGFloat, segments: Int,
                                jitter: CGFloat) -> CGPath {
        let path = UIBezierPath()
        path.move(to: start)
        var current = start
        let segLen = length / CGFloat(segments)

        for i in 0..<segments {
            let progress = CGFloat(i + 1) / CGFloat(segments)
            // Taper jitter toward the tip
            let j = jitter * (1.0 - progress * 0.5)
            let baseX = start.x + cos(angle) * segLen * CGFloat(i + 1)
            let baseY = start.y + sin(angle) * segLen * CGFloat(i + 1)
            let px = baseX + CGFloat.random(in: -j...j)
            let py = baseY + CGFloat.random(in: -j...j)
            let next = CGPoint(x: px, y: py)
            path.addLine(to: next)
            current = next
        }
        _ = current
        return path.cgPath
    }

    // MARK: - Private: Utilities

    private func average(_ pts: [CGPoint]) -> CGPoint {
        var sx: CGFloat = 0; var sy: CGFloat = 0
        for p in pts { sx += p.x; sy += p.y }
        let n = CGFloat(pts.count)
        return CGPoint(x: sx/n, y: sy/n)
    }

    private func glowTexture() -> SKTexture {
        if let t = Self._glowTex { return t }
        let sz       = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: sz)
        let img = renderer.image { ctx in
            let cg     = ctx.cgContext
            cg.setFillColor(UIColor.clear.cgColor)
            cg.fill(CGRect(origin: .zero, size: sz))
            let centre = CGPoint(x: sz.width/2, y: sz.height/2)
            let colors  = [UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.70).cgColor,
                           UIColor(red: 0, green: 0.9, blue: 1, alpha: 0.28).cgColor,
                           UIColor.clear.cgColor] as CFArray
            let locs: [CGFloat] = [0, 0.38, 1]
            let space = CGColorSpaceCreateDeviceRGB()
            if let g = CGGradient(colorsSpace: space, colors: colors, locations: locs) {
                cg.drawRadialGradient(g,
                    startCenter: centre, startRadius: 0,
                    endCenter: centre,   endRadius: sz.width/2,
                    options: .drawsAfterEndLocation)
            }
        }
        let tex = SKTexture(image: img)
        tex.filteringMode = .linear
        Self._glowTex = tex
        return tex
    }
}
