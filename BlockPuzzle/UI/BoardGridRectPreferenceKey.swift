import SwiftUI

struct BoardGridRectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        // Prefer non-zero values.
        if value == .zero { value = next }
    }
}
