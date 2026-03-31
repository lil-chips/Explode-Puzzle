import CoreHaptics
import UIKit
import Foundation

// MARK: - HapticEngine
// CoreHaptics-based tactile feedback.
// Falls back to UIImpactFeedbackGenerator on devices
// that don't support CHHapticEngine (< iPhone 8).

final class HapticEngine {

    // ── Singleton ──────────────────────────────────────────────────
    static let shared = HapticEngine()

    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false

    // ── UIKit fallbacks ────────────────────────────────────────────
    private let lightGen  = UIImpactFeedbackGenerator(style: .light)
    private let medGen    = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen  = UIImpactFeedbackGenerator(style: .heavy)
    private let notifGen  = UINotificationFeedbackGenerator()

    // ── Mute ───────────────────────────────────────────────────────
    var isMuted: Bool = false

    // ── Init ───────────────────────────────────────────────────────
    private init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }
        buildEngine()
        prepareGenerators()
    }

    private func buildEngine() {
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            engine?.stoppedHandler = { [weak self] reason in
                print("[HapticEngine] stopped: \(reason)")
                self?.restartEngine()
            }
            engine?.resetHandler = { [weak self] in
                self?.restartEngine()
            }
            try engine?.start()
        } catch {
            print("[HapticEngine] init error: \(error)")
            supportsHaptics = false
        }
    }

    private func restartEngine() {
        engine?.start { error in
            if let e = error { print("[HapticEngine] restart error: \(e)") }
        }
    }

    private func prepareGenerators() {
        lightGen.prepare()
        medGen.prepare()
        heavyGen.prepare()
        notifGen.prepare()
    }

    // MARK: - ══ PUBLIC HAPTIC API ══

    /// Light tap — block placement
    func hapticPlace() {
        guard !isMuted else { return }
        if supportsHaptics {
            play(sharpness: 0.5, intensity: 0.55, dur: 0.04)
        } else {
            lightGen.impactOccurred(intensity: 0.6)
        }
    }

    /// Medium impact — single line clear
    func hapticClear() {
        guard !isMuted else { return }
        if supportsHaptics {
            play(sharpness: 0.4, intensity: 0.80, dur: 0.06)
        } else {
            medGen.impactOccurred()
        }
    }

    /// Heavy boom — multi-line clear
    func hapticClearMulti(lines: Int) {
        guard !isMuted else { return }
        let intensity = min(1.0, 0.75 + Float(lines) * 0.08)
        if supportsHaptics {
            playDouble(
                i1: intensity * 0.9, s1: 0.3, t1: 0,
                i2: intensity,       s2: 0.5, t2: 0.06
            )
        } else {
            heavyGen.impactOccurred(intensity: CGFloat(intensity))
        }
    }

    /// Ascending series — power streak build-up (step 1…7)
    func hapticStreak(step: Int) {
        guard !isMuted else { return }
        let intensity = min(1.0, 0.35 + Float(step) * 0.10)
        let sharpness = min(1.0, 0.4  + Float(step) * 0.08)
        if supportsHaptics {
            play(sharpness: sharpness, intensity: intensity, dur: 0.05)
        } else {
            lightGen.impactOccurred(intensity: CGFloat(intensity))
        }
    }

    /// MAX power streak — full 7 dots
    func hapticStreakMax() {
        guard !isMuted else { return }
        if supportsHaptics {
            playBurst(count: 3, spacing: 0.06, intensity: 0.95, sharpness: 0.85)
        } else {
            heavyGen.impactOccurred()
        }
    }

    /// Circuit path complete — satisfying "click-click-boom"
    func hapticCircuit() {
        guard !isMuted else { return }
        if supportsHaptics {
            playBurst(count: 3, spacing: 0.055, intensity: 0.88, sharpness: 0.75)
        } else {
            medGen.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.heavyGen.impactOccurred()
            }
        }
    }

    /// Neon event trigger — dramatic rumble + sharp crack
    func hapticEvent() {
        guard !isMuted else { return }
        if supportsHaptics {
            playDouble(
                i1: 0.6, s1: 0.2, t1: 0,
                i2: 1.0, s2: 0.9, t2: 0.10
            )
        } else {
            medGen.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                self.heavyGen.impactOccurred()
            }
        }
    }

    /// Score milestone — escalating triple pulse
    func hapticMilestone() {
        guard !isMuted else { return }
        if supportsHaptics {
            playBurst(count: 4, spacing: 0.07, intensity: 1.0, sharpness: 0.9)
        } else {
            notifGen.notificationOccurred(.success)
        }
    }

    /// Game over — descending decay rumble
    func hapticGameOver() {
        guard !isMuted else { return }
        if supportsHaptics {
            // Three hits, decreasing intensity
            playDouble(i1: 0.95, s1: 0.2, t1: 0,
                       i2: 0.65, s2: 0.2, t2: 0.14)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                self.play(sharpness: 0.2, intensity: 0.40, dur: 0.12)
            }
        } else {
            heavyGen.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                self.medGen.impactOccurred()
            }
        }
    }

    // MARK: - Private CoreHaptics helpers

    private func play(sharpness: Float, intensity: Float, dur: Double) {
        guard let engine else { return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                    ],
                    relativeTime: 0,
                    duration: dur
                )
            ]
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch { /* silent fail on haptic errors */ }
    }

    private func playDouble(i1: Float, s1: Float, t1: Double,
                            i2: Float, s2: Float, t2: Double) {
        guard let engine else { return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient,
                              parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: i1),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: s1)
                              ],
                              relativeTime: t1),
                CHHapticEvent(eventType: .hapticTransient,
                              parameters: [
                                CHHapticEventParameter(parameterID: .hapticIntensity, value: i2),
                                CHHapticEventParameter(parameterID: .hapticSharpness, value: s2)
                              ],
                              relativeTime: t2)
            ]
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    private func playBurst(count: Int, spacing: Double,
                           intensity: Float, sharpness: Float) {
        guard let engine else { return }
        do {
            var events = [CHHapticEvent]()
            for i in 0..<count {
                let t   = Double(i) * spacing
                let int = intensity * (1.0 - Float(i) * 0.06)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: int),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                    ],
                    relativeTime: t
                ))
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }
}
