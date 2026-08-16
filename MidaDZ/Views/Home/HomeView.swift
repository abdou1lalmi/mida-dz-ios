import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var catalog: RecipeCatalog
    @EnvironmentObject private var library: UserLibraryStore
    @State private var searchText = ""
    @State private var selectedRecipe: Recipe?
    @State private var selectedCategory: RecipeCategory?
    @State private var selectedRegion: Region?
    @ScaledMetric(relativeTo: .largeTitle) private var greetingSize: CGFloat = 34

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: MidaSpacing.sm)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MidaSpacing.xl) {
                    greeting
                    SearchBar(text: $searchText)
                        .onSubmit { catalog.filter.query = searchText }
                    if let featured = catalog.featured {
                        featuredSection(featured)
                    }
                    if !catalog.recipes.isEmpty {
                        regionSection
                        popularSection
                        categoriesSection
                        quickSection
                        traditionSection
                    } else if case .loading = catalog.state {
                        loadingContent
                    }
                }
                .padding(.horizontal, MidaSpacing.md)
                .padding(.top, MidaSpacing.sm)
                .padding(.bottom, MidaSpacing.xxl)
            }
            .background(MidaColor.parchment.opacity(0.25).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedRecipe) { recipe in RecipeDetailView(recipe: recipe) }
            .sheet(item: $selectedCategory) { category in DiscoverView(initialCategory: category) }
            .sheet(item: $selectedRegion) { region in DiscoverView(initialRegion: region) }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good morning")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MidaColor.olive)
            Text("What's cooking today?")
                .font(.system(size: greetingSize, weight: .bold, design: .rounded))
                .foregroundStyle(MidaColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, MidaSpacing.sm)
    }

    private func featuredSection(_ recipe: Recipe) -> some View {
        Button { selectedRecipe = recipe } label: {
            ZStack(alignment: .bottomLeading) {
                MidaArtworkView(key: recipe.imageName, height: 350, cornerRadius: MidaRadius.large)
                LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: MidaRadius.large, style: .continuous))
                VStack(alignment: .leading, spacing: 8) {
                    Text("FEATURED FROM ALGERIA")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.82))
                    Text(recipe.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(recipe.shortDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        MetadataChip(symbol: "mappin.and.ellipse", text: recipe.primaryRegion.title)
                        MetadataChip(symbol: "clock", text: recipe.totalTimeLabel)
                    }
                }
                .padding(MidaSpacing.lg)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Featured recipe: \(recipe.name)")
        .accessibilityHint("Opens recipe details")
    }

    private var regionSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            SectionHeader(title: "Explore Algeria", subtitle: "Recipes shaped by place")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MidaSpacing.sm) {
                    ForEach([Region.algiers, .oran, .constantine, .kabylie, .sahara, .aures], id: \.self) { region in
                        Button { selectedRegion = region } label: { RegionCard(region: region) }
                            .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            SectionHeader(title: "Popular recipes", subtitle: "Beloved around the table")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: MidaSpacing.md) {
                    ForEach(catalog.popular) { recipe in
                        Button { selectedRecipe = recipe } label: {
                            RecipeCard(recipe: recipe, isFavorite: library.isFavorite(recipe)) { library.toggleFavorite(recipe) }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            SectionHeader(title: "What are you cooking?", subtitle: "Start with a feeling")
            LazyVGrid(columns: columns, spacing: MidaSpacing.sm) {
                ForEach(RecipeCategory.allCases.prefix(8)) { category in
                    Button { selectedCategory = category } label: {
                        CategoryCard(category: category, count: catalog.recipes.filter { $0.categories.contains(category) }.count)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quickSection: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            SectionHeader(title: "Quick & easy", subtitle: "Good food, less waiting")
            ForEach(catalog.quick.prefix(4)) { recipe in
                Button { selectedRecipe = recipe } label: {
                    CompactRecipeRow(recipe: recipe, isFavorite: library.isFavorite(recipe)) { library.toggleFavorite(recipe) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var traditionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("From our traditions").sectionTitleStyle()
            Text("Every Algerian kitchen has its own version. MIDA DZ keeps the stories close while making each recipe easier to cook today.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .midaCard()
        }
    }

    private var loadingContent: some View {
        VStack(spacing: MidaSpacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: MidaRadius.medium).fill(Color.primary.opacity(0.08)).frame(height: 120).redacted(reason: .placeholder)
            }
        }
        .accessibilityLabel("Loading recipes")
    }
}
