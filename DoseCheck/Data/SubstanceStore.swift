import Foundation

struct CategoryGroup: Identifiable {
    let name: String
    let items: [Substance]
    var id: String { name }
}

@MainActor
final class SubstanceStore: ObservableObject {
    @Published private(set) var substances: [Substance] = []

    init() {
        load()
    }

    private func load() {
        guard
            let url = Bundle.main.url(forResource: "substances", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([Substance].self, from: data)
        else {
            return
        }
        substances = items.sorted { $0.name < $1.name }
    }

    /// Substances grouped by category. Edibles first, then medication, then the rest.
    var categories: [CategoryGroup] {
        let order = ["Drinks & food", "Medication"]
        let grouped = Dictionary(grouping: substances, by: { $0.category })
        let names = grouped.keys.sorted { a, b in
            let ia = order.firstIndex(of: a) ?? order.count
            let ib = order.firstIndex(of: b) ?? order.count
            return ia == ib ? a < b : ia < ib
        }
        return names.map { CategoryGroup(name: $0, items: grouped[$0] ?? []) }
    }

    func search(_ query: String) -> [Substance] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return substances }
        return substances.filter { s in
            s.name.lowercased().contains(q)
                || s.category.lowercased().contains(q)
                || s.aliases.contains { $0.lowercased().contains(q) }
        }
    }
}
