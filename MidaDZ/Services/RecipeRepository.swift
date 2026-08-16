import Foundation

protocol RecipeRepository: Sendable {
    func fetchRecipes() async throws -> [Recipe]
}

struct LocalRecipeRepository: RecipeRepository {
    func fetchRecipes() async throws -> [Recipe] { SampleRecipes.all }
}

@MainActor
final class RecipeCatalog: ObservableObject {
    enum State: Equatable { case loading, loaded, failed(String) }

    @Published private(set) var state: State = .loading
    @Published private(set) var recipes: [Recipe] = []
    @Published var filter: RecipeFilter = .empty

    private let repository: any RecipeRepository

    init(repository: any RecipeRepository = LocalRecipeRepository()) { self.repository = repository }

    func load() async {
        state = .loading
        do {
            recipes = try await repository.fetchRecipes()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let query = filter.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let searchable = ([recipe.name, recipe.arabicName, recipe.frenchName, recipe.englishName, recipe.shortDescription] + recipe.tags + recipe.ingredients.map(\.name) + recipe.regions.map(\.title) + recipe.categories.map(\.title)).joined(separator: " ").lowercased()
            let matchesQuery = query.isEmpty || searchable.contains(query)
            let matchesCategory = filter.category == nil || recipe.categories.contains(filter.category!)
            let matchesRegion = filter.region == nil || recipe.regions.contains(filter.region!)
            let matchesDifficulty = filter.difficulty == nil || recipe.difficulty == filter.difficulty
            let matchesTime = filter.maximumMinutes == nil || recipe.totalMinutes <= filter.maximumMinutes!
            return matchesQuery && matchesCategory && matchesRegion && matchesDifficulty && matchesTime
        }
    }

    var popular: [Recipe] { Array(recipes.prefix(8)) }
    var featured: Recipe? { recipes.first }
    var quick: [Recipe] { recipes.filter { $0.totalMinutes <= 35 }.prefix(8).map { $0 } }

    func resetFilters() { filter = .empty }
}
