import SwiftUI

/// Centralized palette for the early MVP wood theme.
///
/// Keep this intentionally tiny (no assets yet) so iteration stays fast.
enum Theme {
    enum Wood {
        /// Screen background.
        static let backgroundTop = Color(red: 0.38, green: 0.24, blue: 0.13)
        static let backgroundBottom = Color(red: 0.22, green: 0.14, blue: 0.08)

        /// Board frame.
        static let frameFill = Color(red: 0.85, green: 0.74, blue: 0.60)
        static let frameStroke = Color(red: 0.55, green: 0.40, blue: 0.26)

        /// Empty cell slot.
        static let slotFill = Color(red: 0.92, green: 0.86, blue: 0.77)
        static let slotStroke = Color(red: 0.74, green: 0.63, blue: 0.52)

        /// Slightly stronger separators every 5 cells (10x10 board feels like 2x2 sub-grids).
        static let subgridStroke = Color.black.opacity(0.18)

        /// Filled blocks (stained wood / lacquer).
        static let blockPalette: [Color] = [
            Color(red: 0.69, green: 0.33, blue: 0.22), // redwood
            Color(red: 0.22, green: 0.52, blue: 0.38), // teal stain
            Color(red: 0.55, green: 0.46, blue: 0.16), // olive
            Color(red: 0.83, green: 0.56, blue: 0.23), // amber
            Color(red: 0.43, green: 0.30, blue: 0.57), // purple stain
            Color(red: 0.78, green: 0.70, blue: 0.26)  // warm yellow
        ]
    }
}
