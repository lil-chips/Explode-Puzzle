import SwiftUI

struct BoardContainerView: View {
    let gameState: GameState
    let ghostCells: Set<BlockPuzzlePoint>?
    let ghostColor: Color?
    let ghostValid: Bool
    let clearOverlay: [BlockPuzzlePoint: Int]
    let clearFadeOut: Bool
    let boardShake: CGFloat
    @ObservedObject var effects: BoardEffectsController
    let onGridRectChange: (CGRect) -> Void
    let onBoardFrameChange: (CGRect) -> Void

    var body: some View {
        ZStack {
            BoardView(
                gameState: gameState,
                ghostCells: ghostCells,
                ghostColor: ghostColor,
                ghostValid: ghostValid,
                clearOverlay: clearOverlay,
                clearFadeOut: clearFadeOut
            )
            .onPreferenceChange(BoardGridRectPreferenceKey.self) { newValue in
                onGridRectChange(newValue)
            }
            .animation(.spring(response: 0.18, dampingFraction: 0.65), value: boardShake)
            .offset(x: boardShake)

            BoardEffectsOverlayView(controller: effects)
                .allowsHitTesting(false)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.Neon.frameFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Neon.frameStroke, lineWidth: 3)
        )
        .padding(.horizontal, 20)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { onBoardFrameChange(geo.frame(in: .global)) }
                    .onChange(of: geo.frame(in: .global)) { _, newValue in onBoardFrameChange(newValue) }
            }
        )
    }
}

#Preview {
    ZStack {
        NeonBackgroundView()
        BoardContainerView(
            gameState: .demo,
            ghostCells: nil,
            ghostColor: nil,
            ghostValid: true,
            clearOverlay: [:],
            clearFadeOut: false,
            boardShake: 0,
            effects: BoardEffectsController(),
            onGridRectChange: { _ in },
            onBoardFrameChange: { _ in }
        )
        .padding()
    }
}
