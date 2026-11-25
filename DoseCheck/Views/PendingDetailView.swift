import SwiftUI

/// Shown for catalog items that have no verified figures yet.
struct PendingDetailView: View {
    let entry: BrowseEntry

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name).font(.title2.bold())
                    Text(entry.category).foregroundStyle(.secondary)
                }
            }

            Section("Data status") {
                Label("No verified figures yet", systemImage: "hourglass")
                    .foregroundStyle(.orange)
                Text("This item is listed, but its numbers are still being checked against sources. Having no numbers does not mean it is safe.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                PoisonControlButton()
            }
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { SafetyFooter() }
    }
}
