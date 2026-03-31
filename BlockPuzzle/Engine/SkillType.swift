import SwiftUI
import Foundation

// MARK: - Skill definitions
// Each skill can be purchased in the Market and used in-game by drag + drop.

enum SkillType: String, CaseIterable, Codable, Identifiable {
    case clearRow   = "clearRow"
    case clearCol   = "clearCol"
    case clearBoth  = "clearBoth"
    case clear3Rows = "clear3Rows"
    case clear3Cols = "clear3Cols"
    case blast3x3   = "blast3x3"

    var id: String { rawValue }

    // MARK: Display

    var title: String {
        switch self {
        case .clearRow:   return "Clear Row"
        case .clearCol:   return "Clear Column"
        case .clearBoth:  return "Clear Both"
        case .clear3Rows: return "Clear 3 Rows"
        case .clear3Cols: return "Clear 3 Cols"
        case .blast3x3:   return "3×3 Blast"
        }
    }

    var shortTitle: String {
        switch self {
        case .clearRow:   return "ROW"
        case .clearCol:   return "COL"
        case .clearBoth:  return "BOTH"
        case .clear3Rows: return "3×ROW"
        case .clear3Cols: return "3×COL"
        case .blast3x3:   return "BLAST"
        }
    }

    var cost: Int {
        switch self {
        case .clearRow, .clearCol:         return 200
        case .clearBoth, .blast3x3:        return 400
        case .clear3Rows, .clear3Cols:     return 600
        }
    }

    var color: Color {
        switch self {
        case .clearRow, .clear3Rows:  return Theme.Neon.pink
        case .clearCol, .clear3Cols:  return Theme.Neon.cyan
        case .clearBoth:              return Theme.Neon.purple
        case .blast3x3:               return Theme.Neon.orange
        }
    }

    var icon: String {
        switch self {
        case .clearRow:   return "minus.rectangle.fill"
        case .clearCol:   return "rectangle.portrait.fill"
        case .clearBoth:  return "plus.rectangle.fill"
        case .clear3Rows: return "line.3.horizontal"
        case .clear3Cols: return "line.3.vertical"
        case .blast3x3:   return "burst.fill"
        }
    }

    // MARK: Inventory key

    var storageKey: String { "neonpuzzles.skill.\(rawValue)" }

    // MARK: Preview — cells affected on the board for a given target

    func previewCells(target: BlockPuzzlePoint, boardWidth: Int, boardHeight: Int) -> Set<BlockPuzzlePoint> {
        let x = max(0, min(boardWidth  - 1, target.x))
        let y = max(0, min(boardHeight - 1, target.y))

        switch self {

        case .clearRow:
            return Set((0..<boardWidth).map { BlockPuzzlePoint($0, y) })

        case .clearCol:
            return Set((0..<boardHeight).map { BlockPuzzlePoint(x, $0) })

        case .clearBoth:
            let row = Set((0..<boardWidth) .map { BlockPuzzlePoint($0, y) })
            let col = Set((0..<boardHeight).map { BlockPuzzlePoint(x, $0) })
            return row.union(col)

        case .clear3Rows:
            var cells = Set<BlockPuzzlePoint>()
            for dy in -1...1 {
                let ty = max(0, min(boardHeight - 1, y + dy))
                for tx in 0..<boardWidth { cells.insert(BlockPuzzlePoint(tx, ty)) }
            }
            return cells

        case .clear3Cols:
            var cells = Set<BlockPuzzlePoint>()
            for dx in -1...1 {
                let tx = max(0, min(boardWidth - 1, x + dx))
                for ty in 0..<boardHeight { cells.insert(BlockPuzzlePoint(tx, ty)) }
            }
            return cells

        case .blast3x3:
            var cells = Set<BlockPuzzlePoint>()
            for dy in -1...1 {
                for dx in -1...1 {
                    let tx = max(0, min(boardWidth  - 1, x + dx))
                    let ty = max(0, min(boardHeight - 1, y + dy))
                    cells.insert(BlockPuzzlePoint(tx, ty))
                }
            }
            return cells
        }
    }
}

// MARK: - Skill Inventory (UserDefaults helpers)

struct SkillInventory {
    static func count(_ skill: SkillType) -> Int {
        UserDefaults.standard.integer(forKey: skill.storageKey)
    }

    static func add(_ skill: SkillType, quantity: Int = 1) {
        UserDefaults.standard.set(count(skill) + quantity, forKey: skill.storageKey)
    }

    /// Decrements count by 1 and returns true if successful.
    static func use(_ skill: SkillType) -> Bool {
        let c = count(skill)
        guard c > 0 else { return false }
        UserDefaults.standard.set(c - 1, forKey: skill.storageKey)
        return true
    }

    /// Returns all counts as a dictionary.
    static func allCounts() -> [String: Int] {
        SkillType.allCases.reduce(into: [:]) { $0[$1.rawValue] = count($1) }
    }
}
