import Foundation

struct CategoryGroup: Identifiable {
    let name: String
    let items: [BrowseEntry]
    var id: String { name }
}

@MainActor
final class SubstanceStore: ObservableObject {
    @Published private(set) var entries: [BrowseEntry] = []

    private static let categoryOrder = [
        "Beverages", "Fruits", "Vegetables & mushrooms", "Herbs & spices",
        "Nuts, seeds & legumes", "Grains & bread", "Meat, fish & eggs",
        "Dairy & alternatives", "Sweets & snacks", "Prepared foods",
        "Condiments, oils & baking", "Vitamins & minerals",
        "Herbal & dietary supplements", "Over-the-counter medications",
        "Prescription medications",
        "Household products", "Poisonous plants & fungi", "Tobacco & nicotine"
    ]

    init() {
        load()
    }

    private static func decode<T: Decodable>(_ type: T.Type, from file: String) -> T? {
        guard
            let url = Bundle.main.url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func load() {
        let substances = Self.decode([Substance].self, from: "substances") ?? []
        let catalog = Self.decode([CatalogItem].self, from: "catalog") ?? []

        var all = substances.map {
            BrowseEntry(id: $0.id, name: $0.name, category: $0.category, substance: $0)
        }
        all += catalog.map {
            BrowseEntry(id: "catalog-" + $0.id, name: $0.name, category: $0.category, substance: nil)
        }
        entries = all.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var fullDataCount: Int {
        entries.filter { $0.hasData }.count
    }

    /// Entries grouped by category in a fixed order; unknown categories go last.
    var categories: [CategoryGroup] {
        let grouped = Dictionary(grouping: entries, by: { $0.category })
        let names = grouped.keys.sorted { a, b in
            let ia = Self.categoryOrder.firstIndex(of: a) ?? Self.categoryOrder.count
            let ib = Self.categoryOrder.firstIndex(of: b) ?? Self.categoryOrder.count
            return ia == ib ? a < b : ia < ib
        }
        return names.map { CategoryGroup(name: $0, items: grouped[$0] ?? []) }
    }

    /// Matches name, category or aliases. Entries with full data come first.
    func search(_ query: String) -> [BrowseEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return entries }
        let hits = entries.filter { e in
            e.name.lowercased().contains(q)
                || e.category.lowercased().contains(q)
                || (e.substance?.aliases.contains { $0.lowercased().contains(q) } ?? false)
        }
        return hits.filter { $0.hasData } + hits.filter { !$0.hasData }
    }
}
