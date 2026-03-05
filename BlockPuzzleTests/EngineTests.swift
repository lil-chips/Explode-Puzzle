import XCTest
@testable import BlockPuzzle

@MainActor
final class EngineTests: XCTestCase {
    func testCanPlaceAndPlace() {
        var board = Board(width: 4, height: 4)
        let piece = Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0)])

        XCTAssertTrue(board.canPlace(piece, at: BlockPuzzlePoint(0,0)))
        board.place(piece, at: BlockPuzzlePoint(0,0), colorIndex: 0)
        XCTAssertFalse(board.canPlace(piece, at: BlockPuzzlePoint(0,0)))
        XCTAssertTrue(board.isOccupied(BlockPuzzlePoint(0,0)))
        XCTAssertTrue(board.isOccupied(BlockPuzzlePoint(1,0)))
    }

    func testClearFullRow() {
        // Fill row y=0
        var board = Board(width: 3, height: 3, occupied: [
            BlockPuzzlePoint(0,0): 0,
            BlockPuzzlePoint(1,0): 0,
            BlockPuzzlePoint(2,0): 0,
        ])
        let cleared = board.clearFullLines()
        XCTAssertEqual(cleared.rows, 1)
        XCTAssertEqual(cleared.cols, 0)
        XCTAssertTrue(board.occupied.isEmpty)
    }

    func testClearFullCol() {
        var board = Board(width: 3, height: 3, occupied: [
            BlockPuzzlePoint(0,0): 0,
            BlockPuzzlePoint(0,1): 0,
            BlockPuzzlePoint(0,2): 0,
        ])
        let cleared = board.clearFullLines()
        XCTAssertEqual(cleared.rows, 0)
        XCTAssertEqual(cleared.cols, 1)
        XCTAssertTrue(board.occupied.isEmpty)
    }

    func testGameOverDetection() {
        // Fill all but one cell.
        let board = Board(width: 2, height: 2, occupied: [
            BlockPuzzlePoint(0,0): 0,
            BlockPuzzlePoint(1,0): 0,
            BlockPuzzlePoint(0,1): 0,
        ])
        let state = GameState(board: board, currentPieces: [Piece(cells: [BlockPuzzlePoint(0,0), BlockPuzzlePoint(1,0)])], score: 0)
        XCTAssertTrue(state.isGameOver())
    }
}
