import Foundation

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
