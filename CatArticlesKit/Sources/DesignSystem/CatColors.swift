import SwiftUI

/// Color palette mirroring `core/designsystem/colors.xml` from the Android sample.
public extension Color {
    /// Coral/salmon brand color (`#F2545B`).
    static let catPrimary = Color(hex: 0xF2545B)
    static let catBackgroundLight = Color(hex: 0xF4EBF4)
    static let catBackgroundDark = Color(hex: 0x2B292B)
    static let catSurfaceLight = Color(hex: 0xD0C7C7)
    static let catSurfaceDark = Color(hex: 0x424242)

    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

/// Background that adapts to the color scheme, like `LocalBackgroundTheme`.
public struct CatBackground: View {
    @Environment(\.colorScheme) private var scheme
    public init() {}
    public var body: some View {
        (scheme == .dark ? Color.catBackgroundDark : Color.catBackgroundLight)
            .ignoresSafeArea()
    }
}

public extension View {
    /// Applies the app's adaptive background behind this view.
    func catBackground() -> some View {
        background(CatBackground())
    }
}
