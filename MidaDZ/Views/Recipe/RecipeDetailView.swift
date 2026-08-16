import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject private var library: UserLibraryStore
    @Environment(\.dismiss) private var dismiss
    @State private var servings: Int
    @State private var showCookingMode = false
    @State private var showCollectionPicker = false
    @ScaledMetric(relativeTo: .largeTitle) private var recipeTitleSize: CGFloat = 32

    init(recipe: Recipe) {
        self.recipe = recipe
        _servings = State(initialValue: recipe.servings)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MidaSpacing.xl) {
                    MidaArtworkView(key: recipe.imageName, height: 330, cornerRadius: 0)
                        .overlay(alignment: .bottomLeading) { heroOverlay }
                        .ignoresSafeArea(edges: .top)
                    VStack(alignment: .leading, spacing: MidaSpacing.lg) {
                        titleBlock
                        metadata
                        ingredientSection
                        preparationSection
                        noteSection
                        Button { showCookingMode = true } label: {
                            Label("Start Cooking", systemImage: "play.fill")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(MidaColor.olive, in: RoundedRectangle(cornerRadius: MidaRadius.medium, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens one-step-at-a-time Cooking Mode")
                    }
                    .padding(.horizontal, MidaSpacing.md)
                    .padding(.bottom, MidaSpacing.xxl)
                }
            }
            .background(MidaColor.parchment.opacity(0.25).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { dismiss() } label: { Image(systemName: "chevron.backward") }.accessibilityLabel("Back") }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    FavoriteButton(isFavorite: library.isFavorite(recipe)) { library.toggleFavorite(recipe) }
                    Menu {
                        ForEach(library.collections) { collection in
                            Button { library.add(recipe, to: collection.id); showCollectionPicker = false } label: { Label(collection.name, systemImage: collection.symbol) }
                        }
                        ShareLink(item: "Try \(recipe.name) in MIDA DZ") { Label("Share recipe", systemImage: "square.and.arrow.up") }
                    } label: { Image(systemName: "ellipsis.circle.fill").font(.title3).foregroundStyle(.primary).frame(width: 44, height: 44) }
                    .accessibilityLabel("Recipe actions")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showCookingMode) { CookingModeView(recipe: recipe, servings: servings) }
            .onAppear { library.recordView(recipe) }
        }
    }

    private var heroOverlay: some View {
        LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
            .allowsHitTesting(false)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name).font(.system(size: recipeTitleSize, weight: .bold, design: .rounded)).foregroundStyle(MidaColor.ink)
            Text(recipe.englishName).font(.subheadline.weight(.medium)).foregroundStyle(MidaColor.olive)
            Text(recipe.shortDescription).font(.body).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private var metadata: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetadataChip(symbol: "mappin.and.ellipse", text: recipe.primaryRegion.title)
            MetadataChip(symbol: "clock", text: recipe.totalTimeLabel)
            MetadataChip(symbol: "chart.bar.fill", text: recipe.difficulty.label)
            MetadataChip(symbol: "person.2.fill", text: "\(servings) servings")
        }
    }

    private var ingredientSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.md) {
            SectionHeader(title: "Ingredients", subtitle: "Scaled for your table")
            HStack {
                Text("Servings").font(.subheadline.weight(.semibold))
                Spacer()
                Stepper(value: $servings, in: 1...20) { Text("\(servings)").font(.headline.monospacedDigit()) }
                    .labelsHidden()
                Text("\(servings)").font(.headline.monospacedDigit()).frame(minWidth: 28)
            }
            .padding(.vertical, 4)
            ForEach(recipe.ingredients) { ingredient in
                HStack(alignment: .firstTextBaseline, spacing: MidaSpacing.sm) {
                    Circle().fill(MidaColor.saffron).frame(width: 7, height: 7)
                    Text(ingredient.name).font(.body)
                    Spacer()
                    Text(ingredient.scaled(for: servings, baseServings: recipe.servings)).font(.subheadline.weight(.semibold)).foregroundStyle(MidaColor.olive)
                    if let note = ingredient.note { Text(note).font(.caption).foregroundStyle(.secondary) }
                }
                Divider()
            }
        }
    }

    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.md) {
            SectionHeader(title: "Preparation", subtitle: "Take it one calm step at a time")
            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: MidaSpacing.md) {
                    Text("\(index + 1)").font(.headline.weight(.bold)).foregroundStyle(.white).frame(width: 32, height: 32).background(MidaColor.olive, in: Circle())
                    Text(instruction).font(.body).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.md) {
            if !recipe.cookingTips.isEmpty {
                Label("Cooking tip", systemImage: "lightbulb.fill").font(.headline).foregroundStyle(MidaColor.saffron)
                Text(recipe.cookingTips.joined(separator: " ")).font(.body).foregroundStyle(.secondary).midaCard()
            }
            Label("From the tradition", systemImage: "book.closed.fill").font(.headline).foregroundStyle(MidaColor.olive)
            Text(recipe.traditionalNote).font(.body).foregroundStyle(.secondary).midaCard()
        }
    }
}
