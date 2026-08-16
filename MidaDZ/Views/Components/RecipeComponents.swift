import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).sectionTitleStyle()
                if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MidaColor.olive)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var prompt: String = "Search recipes, ingredients, regions"
    var body: some View {
        HStack(spacing: MidaSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, MidaSpacing.md)
        .frame(minHeight: 50)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: MidaRadius.pill, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: MidaRadius.pill).strokeBorder(Color.primary.opacity(0.08)) }
        .accessibilityElement(children: .contain)
    }
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .symbolRenderingMode(.hierarchical)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isFavorite ? MidaColor.clay : .primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favourites" : "Save to favourites")
        .accessibilityValue(isFavorite ? "Saved" : "Not saved")
    }
}

struct MetadataChip: View {
    let symbol: String
    let text: String
    var body: some View {
        Label(text, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.primary.opacity(0.06), in: Capsule())
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            ZStack(alignment: .topTrailing) {
                MidaArtworkView(key: recipe.imageName, height: 150, cornerRadius: MidaRadius.medium)
                FavoriteButton(isFavorite: isFavorite, action: onFavorite)
                    .padding(10)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(MidaColor.ink)
                    .lineLimit(2)
                Text(recipe.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    MetadataChip(symbol: "clock", text: recipe.totalTimeLabel)
                    MetadataChip(symbol: "chart.bar.fill", text: recipe.difficulty.label)
                }
            }
        }
        .frame(width: 250, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to open recipe")
    }
}

struct CompactRecipeRow: View {
    let recipe: Recipe
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: MidaSpacing.md) {
            MidaArtworkView(key: recipe.imageName, height: 82, cornerRadius: MidaRadius.small)
                .frame(width: 92)
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.name).font(.headline).lineLimit(2)
                Text(recipe.primaryRegion.title).font(.subheadline).foregroundStyle(.secondary)
                Text("\(recipe.totalTimeLabel) · \(recipe.difficulty.label)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            FavoriteButton(isFavorite: isFavorite, action: onFavorite)
                .scaleEffect(0.82)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct CategoryCard: View {
    let category: RecipeCategory
    let count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: category.symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(MidaColor.saffron)
            Text(category.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MidaColor.ink)
                .lineLimit(2)
            Text("\(count) recipes")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 142, height: 118, alignment: .leading)
        .padding(MidaSpacing.md)
        .background(MidaColor.parchment.opacity(0.65), in: RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: MidaRadius.medium).strokeBorder(MidaColor.saffron.opacity(0.15)) }
        .accessibilityElement(children: .combine)
    }
}

struct RegionCard: View {
    let region: Region
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MidaArtworkView(key: region.rawValue, height: 170, cornerRadius: MidaRadius.medium)
            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(region.title).font(.headline.weight(.bold)).foregroundStyle(.white)
                Text(region.shortDescription).font(.caption).foregroundStyle(.white.opacity(0.82)).lineLimit(2)
            }
            .padding(14)
        }
        .frame(width: 190)
        .accessibilityElement(children: .combine)
    }
}

struct EmptyState: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: symbol)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action { Button(actionTitle, action: action).tint(MidaColor.olive) }
        }
        .padding(.vertical, MidaSpacing.xl)
    }
}
