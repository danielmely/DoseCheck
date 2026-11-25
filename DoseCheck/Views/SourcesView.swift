import SwiftUI

/// Every source used by the figures in the app, with the number of items that cite it.
struct SourcesView: View {
    @EnvironmentObject private var store: SubstanceStore
    @Environment(\.dismiss) private var dismiss

    private struct Row: Identifiable {
        let source: SourceRef
        let count: Int
        var id: String { source.title }
    }

    private var rows: [Row] {
        var counts: [String: (SourceRef, Int)] = [:]
        for entry in store.entries {
            guard let s = entry.substance else { continue }
            for source in s.sources {
                let existing = counts[source.title]
                counts[source.title] = (existing?.0.url == nil ? source : existing!.0, (existing?.1 ?? 0) + 1)
            }
        }
        return counts.values
            .map { Row(source: $0.0, count: $0.1) }
            .sorted { $0.source.title.localizedCaseInsensitiveCompare($1.source.title) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Figures come from regulators, government health agencies, drug labels and published studies. Each item lists its own sources on its page. Items marked \"Coming soon\" have no figures yet because nothing is shown until it has a source. All numbers are rough estimates and not medical advice.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("\(rows.count) sources") {
                    ForEach(rows) { row in
                        VStack(alignment: .leading, spacing: 2) {
                            SourceLink(source: row.source)
                            Text(row.count == 1 ? "Used for 1 item" : "Used for \(row.count) items")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}
