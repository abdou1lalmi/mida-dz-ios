import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var catalog: RecipeCatalog
    @EnvironmentObject private var library: UserLibraryStore
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var selectedRecipe: Recipe?
    @State private var selectedCategory: RecipeCategory?
    @State private var selectedRegion: Region?

    var initialCategory: RecipeCategory? = nil
    var initialRegion: Region? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MidaSpacing.lg) {
                    SearchBar(text: $searchText)
                        .onChange(of: searchText) { _, value in catalog.filter.query = value }
                        .onSubmit { library.recordSearch(searchText) }
                    activeFilters
                    if searchText.isEmpty && !catalog.filter.isActive {
                        discoveryShortcuts
                    }
                    results
                }
                .padding(.horizontal, MidaSpacing.md)
                .padding(.top, MidaSpacing.sm)
                .padding(.bottom, MidaSpacing.xxl)
            }
            .background(MidaColor.parchment.opacity(0.25).ignoresSafeArea())
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showFilters = true } label: {
                        Image(systemName: catalog.filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter recipes")
                }
            }
            .sheet(isPresented: $showFilters) { FilterSheet() }
            .sheet(item: $selectedRecipe) { recipe in RecipeDetailView(recipe: recipe) }
            .onAppear {
                if let initialCategory { catalog.filter.category = initialCategory }
                if let initialRegion { catalog.filter.region = initialRegion }
            }
        }
    }

    @ViewBuilder private var activeFilters: some View {
        if catalog.filter.isActive {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let category = catalog.filter.category { filterPill(category.title) { catalog.filter.category = nil } }
                    if let region = catalog.filter.region { filterPill(region.title) { catalog.filter.region = nil } }
                    if let difficulty = catalog.filter.difficulty { filterPill(difficulty.label) { catalog.filter.difficulty = nil } }
                    if let minutes = catalog.filter.maximumMinutes { filterPill("Under \(minutes) min") { catalog.filter.maximumMinutes = nil } }
                    Button("Clear all") { catalog.resetFilters(); searchText = "" }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MidaColor.clay)
                }
            }
        }
    }

    private func filterPill(_ label: String, remove: @escaping () -> Void) -> some View {
        Button(action: remove) {
            HStack(spacing: 5) { Text(label); Image(systemName: "xmark") }
                .font(.caption.weight(.semibold))
                .foregroundStyle(MidaColor.olive)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(MidaColor.olive.opacity(0.11), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var discoveryShortcuts: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.md) {
            SectionHeader(title: "Browse by category", subtitle: "A little direction for tonight")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MidaSpacing.sm) {
                    ForEach(RecipeCategory.allCases) { category in
                        Button {
                            catalog.filter.category = category
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: category.symbol).font(.title3)
                                Text(category.title).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
                            }
                            .foregroundStyle(MidaColor.ink)
                            .frame(width: 88, height: 82)
                            .background(MidaColor.parchment, in: RoundedRectangle(cornerRadius: MidaRadius.small, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            SectionHeader(title: "Recent searches")
            if library.recentSearches.isEmpty {
                Text("Your searches will appear here.").font(.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(library.recentSearches, id: \.self) { query in
                    Button {
                        searchText = query
                        catalog.filter.query = query
                    } label: {
                        Label(query, systemImage: "clock.arrow.circlepath")
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: MidaSpacing.sm) {
            SectionHeader(title: catalog.filter.isActive ? "Matching recipes" : "All recipes", subtitle: "\(catalog.filteredRecipes.count) recipes")
            if catalog.filteredRecipes.isEmpty {
                EmptyState(symbol: "magnifyingglass", title: "No recipes found", message: "Try a different ingredient, region, or category.", actionTitle: "Clear filters") {
                    catalog.resetFilters(); searchText = ""
                }
            } else {
                LazyVStack(spacing: MidaSpacing.sm) {
                    ForEach(catalog.filteredRecipes) { recipe in
                        Button { selectedRecipe = recipe } label: {
                            CompactRecipeRow(recipe: recipe, isFavorite: library.isFavorite(recipe)) { library.toggleFavorite(recipe) }
                                .midaCard(padding: 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct FilterSheet: View {
    @EnvironmentObject private var catalog: RecipeCatalog
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: Binding(get: { catalog.filter.category }, set: { catalog.filter.category = $0 })) {
                        Text("Any category").tag(RecipeCategory?.none)
                        ForEach(RecipeCategory.allCases) { Text($0.title).tag(Optional($0)) }
                    }
                }
                Section("Region") {
                    Picker("Region", selection: Binding(get: { catalog.filter.region }, set: { catalog.filter.region = $0 })) {
                        Text("Any region").tag(Region?.none)
                        ForEach(Region.allCases) { Text($0.title).tag(Optional($0)) }
                    }
                }
                Section("Difficulty") {
                    Picker("Difficulty", selection: Binding(get: { catalog.filter.difficulty }, set: { catalog.filter.difficulty = $0 })) {
                        Text("Any level").tag(Difficulty?.none)
                        ForEach(Difficulty.allCases) { Text($0.label).tag(Optional($0)) }
                    }
                }
                Section("Time") {
                    Picker("Maximum time", selection: Binding(get: { catalog.filter.maximumMinutes }, set: { catalog.filter.maximumMinutes = $0 })) {
                        Text("Any duration").tag(Int?.none)
                        Text("Under 30 min").tag(Optional(30))
                        Text("Under 45 min").tag(Optional(45))
                        Text("Under 60 min").tag(Optional(60))
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .cancellationAction) { Button("Reset") { catalog.resetFilters() } }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
