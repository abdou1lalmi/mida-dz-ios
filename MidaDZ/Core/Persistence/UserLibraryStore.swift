import Foundation

@MainActor
final class UserLibraryStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String>
    @Published private(set) var recentRecipeIDs: [String]
    @Published private(set) var recentSearches: [String]
    @Published private(set) var collections: [RecipeCollection]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favoriteIDs = Set(defaults.stringArray(forKey: Keys.favorites) ?? [])
        recentRecipeIDs = defaults.stringArray(forKey: Keys.recentRecipes) ?? []
        recentSearches = defaults.stringArray(forKey: Keys.recentSearches) ?? []
        collections = (try? JSONDecoder().decode([RecipeCollection].self, from: defaults.data(forKey: Keys.collections) ?? Data())) ?? RecipeCollection.defaults
    }

    func isFavorite(_ recipe: Recipe) -> Bool { favoriteIDs.contains(recipe.id) }

    func toggleFavorite(_ recipe: Recipe) {
        if favoriteIDs.contains(recipe.id) { favoriteIDs.remove(recipe.id) }
        else { favoriteIDs.insert(recipe.id) }
        save()
    }

    func recordView(_ recipe: Recipe) {
        recentRecipeIDs.removeAll { $0 == recipe.id }
        recentRecipeIDs.insert(recipe.id, at: 0)
        recentRecipeIDs = Array(recentRecipeIDs.prefix(12))
        save()
    }

    func recordSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(8))
        save()
    }

    func add(_ recipe: Recipe, to collectionID: String) {
        guard let index = collections.firstIndex(where: { $0.id == collectionID }) else { return }
        if !collections[index].recipeIDs.contains(recipe.id) { collections[index].recipeIDs.append(recipe.id) }
        save()
    }

    func recipes(in collectionID: String, from recipes: [Recipe]) -> [Recipe] {
        guard let collection = collections.first(where: { $0.id == collectionID }) else { return [] }
        return collection.recipeIDs.compactMap { id in recipes.first(where: { $0.id == id }) }
    }

    private func save() {
        defaults.set(Array(favoriteIDs), forKey: Keys.favorites)
        defaults.set(recentRecipeIDs, forKey: Keys.recentRecipes)
        defaults.set(recentSearches, forKey: Keys.recentSearches)
        defaults.set(try? JSONEncoder().encode(collections), forKey: Keys.collections)
    }

    private enum Keys {
        static let favorites = "mida.favoriteIDs"
        static let recentRecipes = "mida.recentRecipeIDs"
        static let recentSearches = "mida.recentSearches"
        static let collections = "mida.collections"
    }
}

struct RecipeCollection: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var symbol: String
    var recipeIDs: [String]

    static let defaults = [
        RecipeCollection(id: "ramadan", name: "Ramadan", symbol: "moon.stars.fill", recipeIDs: []),
        RecipeCollection(id: "desserts", name: "Desserts", symbol: "birthday.cake.fill", recipeIDs: []),
        RecipeCollection(id: "family", name: "Family favourites", symbol: "heart.fill", recipeIDs: []),
        RecipeCollection(id: "quick", name: "Quick meals", symbol: "bolt.fill", recipeIDs: []),
        RecipeCollection(id: "try", name: "To try", symbol: "bookmark.fill", recipeIDs: [])
    ]
}
