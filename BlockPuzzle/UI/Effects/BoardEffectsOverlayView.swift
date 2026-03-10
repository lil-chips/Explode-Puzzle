import SwiftUI
import SpriteKit

struct BoardEffectsOverlayView: UIViewRepresentable {
    @ObservedObject var controller: BoardEffectsController

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        skView.isUserInteractionEnabled = false

        let scene = BoardEffectsScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear

        controller.attach(scene: scene)
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        controller.setCanvasSize(uiView.bounds.size)
    }
}
