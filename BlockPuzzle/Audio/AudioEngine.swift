import AVFoundation
import Foundation

// MARK: - AudioEngine
// Fully synthesised game audio — zero external files.
// Each generator is extracted into a named private function to avoid
// Swift type-checker timeouts on complex inline-closure arithmetic.

final class AudioEngine {

    static let shared = AudioEngine()

    private let engine = AVAudioEngine()
    private let mixer  = AVAudioMixerNode()
    private let reverb = AVAudioUnitReverb()

    private static let sr: Double = 44_100
    static let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1)!

    // Round-robin player pool — avoids alloc on every sound event
    private var pool: [AVAudioPlayerNode] = []
    private let poolSize = 12
    private var cursor   = 0
    private let lock     = NSLock()

    var isMuted: Bool = false {
        didSet { mixer.outputVolume = isMuted ? 0 : 0.58 }
    }

    private init() { setup() }

    // MARK: - Setup

    private func setup() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: .mixWithOthers)
        try? session.setActive(true)

        reverb.loadFactoryPreset(.smallRoom)
        reverb.wetDryMix = 10

        engine.attach(mixer)
        engine.attach(reverb)
        engine.connect(mixer,  to: reverb,               format: nil)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = 0.58

        for _ in 0..<poolSize {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: mixer, format: Self.fmt)
            pool.append(node)
        }
        try? engine.start()
    }

    // MARK: - Playback helpers

    private func nextNode() -> AVAudioPlayerNode {
        lock.lock(); defer { lock.unlock() }
        let node = pool[cursor % poolSize]
        cursor += 1
        return node
    }

    private func play(_ buf: AVAudioPCMBuffer?, vol: Float = 0.65) {
        guard !isMuted, let buf = buf else { return }
        let node = nextNode()
        node.volume = vol
        node.scheduleBuffer(buf, at: nil, options: .interrupts)
        if !node.isPlaying { node.play() }
    }

    /// Build a mono PCM buffer.
    /// - Parameter dur: duration in seconds
    /// - Parameter gen: sample generator, t ∈ [0, 1] → Double
    private func mkBuf(dur: Double, gen: (Double) -> Double) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(dur * Self.sr)
        guard let buf = AVAudioPCMBuffer(pcmFormat: Self.fmt,
                                         frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let ch  = buf.floatChannelData![0]
        let inv = 1.0 / (Self.sr * dur)
        for i in 0..<Int(frameCount) {
            ch[i] = Float(gen(Double(i) * inv))
        }
        return buf
    }

    /// Simple ADSR-lite envelope (attack / sustain / release by normalised time).
    private func env(_ t: Double, a: Double = 0.01, r: Double = 0.10) -> Double {
        if t < a          { return t / a }
        if t > 1.0 - r    { return max(0.0, (1.0 - t) / r) }
        return 1.0
    }

    // MARK: - ══ Named generator functions ══
    // One function per sound keeps each closure body trivially simple so the
    // Swift type-checker never times out.

    // 1 — Block placement
    private func genPlace(t: Double, d: Double) -> Double {
        let click: Double = sin(2.0 * .pi * 900.0 * t * d) * env(t, a: 0.005, r: 0.06)
        let thud:  Double = sin(2.0 * .pi * 110.0 * t * d * (1.0 - t * 6.0)) * env(t, a: 0.003, r: 0.04)
        return (click * 0.28 + thud * 0.38) * 0.72
    }

    // 2 — Line clear  (n = number of lines cleared simultaneously)
    private func genClear(t: Double, d: Double, f0: Double, amp: Double) -> Double {
        let freq: Double = f0 * (1.0 + t * 1.8)
        let main: Double = sin(2.0 * .pi * freq       * t * d)
        let harm: Double = sin(2.0 * .pi * freq * 2.01 * t * d) * 0.35
        return (main + harm) * env(t, a: 0.01, r: 0.18) * amp * 0.42
    }

    // 3 — Color burst
    private func genColorBurst(t: Double, d: Double) -> Double {
        let noise: Double = Double.random(in: -1.0...1.0) * 0.4
        let sweep: Double = sin(2.0 * .pi * 800.0 * (1.0 + t * 3.0) * t * d)
        return (noise * 0.3 + sweep * 0.7) * env(t, a: 0.005, r: 0.14) * 0.5
    }

    // 4 — Cascade
    private func genCascade(t: Double, d: Double, freq: Double) -> Double {
        let f: Double = freq * (1.0 + t * 0.6)
        return sin(2.0 * .pi * f * t * d) * env(t, a: 0.004, r: 0.10) * 0.38
    }

    // 5 — Power streak ping
    private func genStreak(t: Double, d: Double, freq: Double) -> Double {
        let body: Double = sin(2.0 * .pi * freq       * t * d)
        let bell: Double = sin(2.0 * .pi * freq * 2.8 * t * d) * 0.28
        return (body + bell) * env(t, a: 0.004, r: 0.10) * 0.32
    }

    // 6 — Level-up arpeggio (per note)
    private func genArpNote(t: Double, d: Double, freq: Double) -> Double {
        let body: Double = sin(2.0 * .pi * freq       * t * d)
        let h2:   Double = sin(2.0 * .pi * freq * 2.0 * t * d) * 0.38
        let h3:   Double = sin(2.0 * .pi * freq * 3.0 * t * d) * 0.18
        return (body + h2 + h3) * env(t, a: 0.006, r: 0.25) * 0.28
    }

    // 7 — Neon event
    private func genEvent(t: Double, d: Double) -> Double {
        let freq: Double = 80.0 + 440.0 * t
        let p:    Double = freq * t * d
        let saw:  Double = (2.0 * (p - floor(p + 0.5))) * 0.3
        let pad:  Double = sin(2.0 * .pi * 220.0 * t * d) * 0.18
        return (saw + pad) * env(t, a: 0.02, r: 0.30) * 0.55
    }

    // 8 — Circuit complete
    private func genCircuit(t: Double, d: Double, freqs: [Double]) -> Double {
        var sample: Double = 0.0
        for freq in freqs {
            sample += sin(2.0 * .pi * freq       * t * d)
            sample += sin(2.0 * .pi * freq * 3.0 * t * d) * 0.22
        }
        return sample * 0.18 * env(t, a: 0.006, r: 0.35) * 0.45
    }

    // 9 — Score milestone (per note, same shape as arp but longer)
    private func genMilestone(t: Double, d: Double, freq: Double) -> Double {
        let body: Double = sin(2.0 * .pi * freq       * t * d)
        let h2:   Double = sin(2.0 * .pi * freq * 2.0 * t * d) * 0.42
        let h3:   Double = sin(2.0 * .pi * freq * 3.0 * t * d) * 0.20
        return (body + h2 + h3) * env(t, a: 0.007, r: 0.32) * 0.26
    }

    // 10 — Game over
    private func genGameOver(t: Double, d: Double) -> Double {
        let freq:   Double = max(38.0, 200.0 * (1.0 - t * 0.72))
        let p:      Double = freq * t * d
        let saw:    Double = (2.0 * (p - floor(p + 0.5))) * 0.28 * env(t, a: 0.02, r: 0.55)
        let rumble: Double = sin(2.0 * .pi * 42.0 * t * d) * env(t, a: 0.05, r: 0.50) * 0.22
        return (saw + rumble) * 0.55
    }

    // MARK: - ══ Public Sound API ══

    /// 1. Block placement — short tactile thud + click.
    func sndPlace() {
        let d: Double = 0.09
        play(mkBuf(dur: d) { [self] t in self.genPlace(t: t, d: d) }, vol: 0.55)
    }

    /// 2. Line clear — sweeping tone scaled by number of lines.
    func sndClear(_ n: Int = 1) {
        let nn:  Int    = max(1, n)
        let d:   Double = 0.28 + Double(nn) * 0.05
        let f0:  Double = 200.0 + Double(nn) * 60.0
        let amp: Double = min(1.0, 0.4 + Double(nn) * 0.2)
        play(mkBuf(dur: d) { [self] t in self.genClear(t: t, d: d, f0: f0, amp: amp) }, vol: 0.72)
    }

    /// 3. Color burst — noise + frequency sweep.
    func sndColorBurst() {
        let d: Double = 0.22
        play(mkBuf(dur: d) { [self] t in self.genColorBurst(t: t, d: d) }, vol: 0.65)
    }

    /// 4. Cascade — rising pitch, scaled by combo depth.
    func sndCascade(depth: Int = 1) {
        let freq: Double = min(2_600.0, 300.0 * pow(1.28, Double(depth)))
        let d:    Double = 0.16
        play(mkBuf(dur: d) { [self] t in self.genCascade(t: t, d: d, freq: freq) }, vol: 0.55)
    }

    /// 5. Power-streak ping — rises with each streak step.
    func sndStreak(step: Int = 1) {
        let freq: Double = 420.0 * pow(1.14, Double(step))
        let d:    Double = 0.14
        play(mkBuf(dur: d) { [self] t in self.genStreak(t: t, d: d, freq: freq) }, vol: 0.50)
    }

    /// 6. Level-up — ascending four-note arpeggio.
    func sndLevelUp() {
        let notes: [Double] = [261.63, 329.63, 392.0, 523.25]
        let d:     Double   = 0.38
        for (i, freq) in notes.enumerated() {
            let delay = Double(i) * 0.09
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                self.play(self.mkBuf(dur: d) { t in self.genArpNote(t: t, d: d, freq: freq) },
                          vol: 0.62)
            }
        }
    }

    /// 7. Neon event — saw-wave sweep for special board events.
    func sndEvent() {
        let d: Double = 0.45
        play(mkBuf(dur: d) { [self] t in self.genEvent(t: t, d: d) }, vol: 0.60)
    }

    /// 8. Circuit complete — rich chord stab.
    func sndCircuit() {
        let freqs: [Double] = [261.63, 392.0, 523.25, 659.25]
        let d:     Double   = 0.55
        play(mkBuf(dur: d) { [self] t in self.genCircuit(t: t, d: d, freqs: freqs) }, vol: 0.72)
    }

    /// 9. Score milestone — five-note ascending fanfare.
    func sndMilestone() {
        let notes: [Double] = [261.63, 329.63, 392.0, 523.25, 659.25]
        let d:     Double   = 0.55
        for (i, freq) in notes.enumerated() {
            let delay = Double(i) * 0.065
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                self.play(self.mkBuf(dur: d) { t in self.genMilestone(t: t, d: d, freq: freq) },
                          vol: 0.75)
            }
        }
    }

    /// 10. Game over — descending rumble + saw fade.
    func sndGameOver() {
        let d: Double = 1.4
        play(mkBuf(dur: d) { [self] t in self.genGameOver(t: t, d: d) }, vol: 0.68)
    }
}
