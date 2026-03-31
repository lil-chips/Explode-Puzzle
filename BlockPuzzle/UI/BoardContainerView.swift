import SwiftUI

struct BoardContainerView: View {
    let gameState: GameState
    let ghostCells: Set<BlockPuzzlePoint>?
    let ghostColor: Color?
    let ghostValid: Bool
    let clearOverlay: [BlockPuzzlePoint: Int]
    let clearFadeOut: Bool
    let boardShake: CGFloat
    let skillPreviewCells: Set<BlockPuzzlePoint>?
    let skillPreviewColor: Color?
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
                clearFadeOut: clearFadeOut,
                skillPreviewCells: skillPreviewCells,
                skillPreviewColor: skillPreviewColor
            )
            .onPreferenceChange(BoardGridRectPreferenceKey.self) { newValue in
                onGridRectChange(newValue)
            }
            .animation(.spring(response: 0.18, dampingFraction: 0.65), value: boardShake)
            .offset(x: boardShake)

            BoardEffectsOverlayView(controller: effects)
                .allowsHitTesting(false)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.Neon.frameFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.Neon.frameStroke, lineWidth: 2.5)
                .shadow(color: Theme.Neon.cyan.opacity(0.20), radius: 12)
        )
        .padding(.horizontal, 12)
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
            skillPreviewCells: nil,
            skillPreviewColor: nil,
            effects: BoardEffectsController(),
            onGridRectChange: { _ in },
            onBoardFrameChange: { _ in }
        )
        .padding()
    }
}
