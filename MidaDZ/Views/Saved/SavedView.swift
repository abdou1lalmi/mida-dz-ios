import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var catalog: RecipeCatalog
    @EnvironmentObject private var library: UserLibraryStore
    @State private var selectedRecipe: Recipe?
    @State private var selectedCollection: RecipeCollection?

    var savedRecipes: [Recipe] { catalog.recipes.filter { library.favoriteIDs.contains($0.id) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MidaSpacing.xl) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Your kitchen shelf").font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(MidaColor.ink)
                        Text("Keep the dishes you want close.").font(.body).foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: MidaSpacing.sm) {
                        SectionHeader(title: "Favourites", subtitle: "\(savedRecipes.count) saved recipes")
                        if savedRecipes.isEmpty {
                            EmptyState(symbol: "heart", title: "Your shelf is waiting", message: "Tap the heart on a recipe to keep it here.")
                        } else {
                            ForEach(savedRecipes) { recipe in
                                Button { selectedRecipe = recipe } label: {
                                    CompactRecipeRow(recipe: recipe, isFavorite: true) { library.toggleFavorite(recipe) }.midaCard(padding: 10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: MidaSpacing.sm) {
                        SectionHeader(title: "Collections", subtitle: "Organise your next table")
                        ForEach(library.collections) { collection in
                            Button { selectedCollection = collection } label: {
                                HStack(spacing: MidaSpacing.md) {
                                    Image(systemName: collection.symbol).font(.title2).foregroundStyle(MidaColor.saffron).frame(width: 42, height: 42).background(MidaColor.saffron.opacity(0.12), in: Circle())
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(collection.name).font(.headline)
                                        Text("\(collection.recipeIDs.count) recipes").font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.forward").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, MidaSpacing.md)
                .padding(.top, MidaSpacing.sm)
                .padding(.bottom, MidaSpacing.xxl)
            }
            .background(MidaColor.parchment.opacity(0.25).ignoresSafeArea())
            .navigationTitle("Saved")
            .sheet(item: $selectedRecipe) { recipe in RecipeDetailView(recipe: recipe) }
            .sheet(item: $selectedCollection) { collection in CollectionDetailView(collection: collection) }
        }
    }
}

private struct CollectionDetailView: View {
    let collection: RecipeCollection
    @EnvironmentObject private var catalog: RecipeCatalog
    @EnvironmentObject private var library: UserLibraryStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            List {
                let recipes = library.recipes(in: collection.id, from: catalog.recipes)
                if recipes.isEmpty {
                    EmptyState(symbol: collection.symbol, title: "Nothing here yet", message: "Save a recipe to this collection from its detail page.")
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(recipes) { recipe in
                        Button { selectedRecipe = recipe } label: {
                            CompactRecipeRow(recipe: recipe, isFavorite: library.isFavorite(recipe)) { library.toggleFavorite(recipe) }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(collection.name)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
            .sheet(item: $selectedRecipe) { recipe in RecipeDetailView(recipe: recipe) }
        }
    }
}
