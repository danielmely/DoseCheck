import SwiftUI

/// Everything in the app, grouped by category. Tap a category to expand it.
struct BrowseView: View {
    @EnvironmentObject private var store: SubstanceStore

    var body: some View {
        List {
            Section {
                Text("\(store.entries.count) items, \(store.fullDataCount) with full data so far.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(store.categories) { group in
                DisclosureGroup("\(group.name) (\(group.items.count))") {
                    ForEach(group.items) { entry in
                        NavigationLink(value: entry) {
                            HStack {
                                Text(entry.name)
                                Spacer()
                                if !entry.hasData {
                                    Text("Coming soon")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { SafetyFooter() }
    }
}
