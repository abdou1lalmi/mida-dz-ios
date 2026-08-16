import SwiftUI

enum MidaColor {
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.10)
    static let parchment = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let saffron = Color(red: 0.86, green: 0.47, blue: 0.16)
    static let olive = Color(red: 0.27, green: 0.35, blue: 0.20)
    static let clay = Color(red: 0.64, green: 0.29, blue: 0.20)
    static let mist = Color(red: 0.91, green: 0.89, blue: 0.83)
    static let card = Color(uiColor: .secondarySystemBackground)
}

enum MidaSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum MidaRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let pill: CGFloat = 100
}

enum MidaArtwork {
    static func gradient(for key: String) -> LinearGradient {
        let palettes: [[Color]] = [
            [MidaColor.saffron, MidaColor.clay],
            [MidaColor.olive, Color(red: 0.52, green: 0.60, blue: 0.30)],
            [MidaColor.clay, Color(red: 0.80, green: 0.54, blue: 0.30)],
            [Color(red: 0.20, green: 0.34, blue: 0.42), Color(red: 0.56, green: 0.69, blue: 0.63)],
            [Color(red: 0.40, green: 0.23, blue: 0.16), Color(red: 0.79, green: 0.61, blue: 0.32)]
        ]
        let index = abs(key.hashValue) % palettes.count
        return LinearGradient(colors: palettes[index], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func symbol(for key: String) -> String {
        if key.contains("tea") || key.contains("coffee") { return "mug.fill" }
        if key.contains("bread") || key.contains("baghrir") || key.contains("sfenj") { return "birthday.cake.fill" }
        if key.contains("fish") || key.contains("moules") { return "fish.fill" }
        if key.contains("soup") || key.contains("chorba") || key.contains("harira") { return "cup.and.saucer.fill" }
        if key.contains("couscous") || key.contains("mesfouf") { return "circle.grid.2x2.fill" }
        if key.contains("salad") || key.contains("chleta") { return "leaf.fill" }
        if key.contains("tajine") || key.contains("mtewem") || key.contains("loubia") { return "flame.fill" }
        return "fork.knife"
    }
}

struct MidaCardModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var padding: CGFloat = MidaSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(reduceTransparency ? Color(uiColor: .secondarySystemBackground) : Color.clear, in: RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous)
                    .fill(reduceTransparency ? AnyShapeStyle(Color.clear) : AnyShapeStyle(.regularMaterial))
            )
            .overlay {
                RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            }
    }
}

extension View {
    func midaCard(padding: CGFloat = MidaSpacing.md) -> some View { modifier(MidaCardModifier(padding: padding)) }

    func sectionTitleStyle() -> some View {
        font(.system(.title3, design: .rounded, weight: .bold))
            .foregroundStyle(MidaColor.ink)
    }
}

struct MidaArtworkView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let key: String
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = MidaRadius.medium

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MidaArtwork.gradient(for: key)
            Circle()
                .fill(.white.opacity(reduceTransparency ? 0.06 : 0.12))
                .frame(width: 180, height: 180)
                .offset(x: 100, y: -50)
            Image(systemName: MidaArtwork.symbol(for: key))
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white.opacity(0.88))
                .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }
}
