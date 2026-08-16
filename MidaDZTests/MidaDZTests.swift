import XCTest
@testable import MidaDZ

final class MidaDZTests: XCTestCase {
    func testCatalogContainsPopulatedOfflineRecipes() {
        XCTAssertGreaterThanOrEqual(SampleRecipes.all.count, 30)
        XCTAssertTrue(SampleRecipes.all.contains { $0.name == "Couscous aux sept légumes" })
        XCTAssertTrue(SampleRecipes.all.contains { $0.name == "Chorba Frik" })
    }

    func testIngredientScalingDoublesQuantity() {
        let ingredient = Ingredient(id: "test", name: "flour", quantity: 250, unit: "g", note: nil)
        XCTAssertEqual(ingredient.scaled(for: 4, baseServings: 2), "500 g")
    }

    @MainActor
    func testCatalogSearchMatchesIngredientsAndRegions() async {
        let catalog = RecipeCatalog()
        await catalog.load()
        catalog.filter.query = "chickpeas"
        XCTAssertFalse(catalog.filteredRecipes.isEmpty)
        catalog.filter = RecipeFilter(category: nil, region: .oran, difficulty: nil, maximumMinutes: nil, query: "")
        XCTAssertTrue(catalog.filteredRecipes.allSatisfy { $0.regions.contains(.oran) })
    }

    @MainActor
    func testFavoritesPersistAcrossStoreInstances() {
        let suiteName = "MidaDZTests.PersistenceIsolation"
        let defaults = UserDefaults(suiteName: suiteName)!
        let first = UserLibraryStore(defaults: defaults)
        let recipe = SampleRecipes.all[0]
        first.toggleFavorite(recipe)
        let second = UserLibraryStore(defaults: defaults)
        XCTAssertTrue(second.isFavorite(recipe))
        defaults.removePersistentDomain(forName: suiteName)
    }
}
