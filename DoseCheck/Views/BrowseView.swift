import SwiftUI

/// Everything in the app, grouped by category. Grows as entries are added
/// to substances.json; categories appear automatically.
struct BrowseView: View {
    @EnvironmentObject private var store: SubstanceStore

    var body: some View {
        List {
            ForEach(store.categories) { group in
                Section("\(group.name) (\(group.items.count))") {
                    ForEach(group.items) { s in
                        NavigationLink(value: s) {
                            Text(s.name)
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
