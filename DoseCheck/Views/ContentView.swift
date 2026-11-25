import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: SubstanceStore
    @EnvironmentObject private var profiles: ProfileStore
    // Not persisted on purpose: the warning shows every time the app opens fresh.
    @State private var acceptedDisclaimer = false
    @State private var query = ""
    @State private var showProfiles = false

    private var profile: Profile { profiles.active ?? .generic }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    searchBar

                    NavigationLink {
                        BrowseView()
                    } label: {
                        Label("Browse", systemImage: "square.grid.2x2")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)

                    if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                        results
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
            }
            .navigationTitle("DoseCheck")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfiles = true } label: {
                        Label(profiles.active?.name ?? "Add person", systemImage: "person.crop.circle")
                            .labelStyle(.titleAndIcon)
                    }
                    .accessibilityLabel("Saved people")
                }
            }
            .navigationDestination(for: BrowseEntry.self) { entry in
                if let s = entry.substance {
                    SubstanceDetailView(substance: s, profile: profile)
                } else {
                    PendingDetailView(entry: entry)
                }
            }
            .safeAreaInset(edge: .bottom) { SafetyFooter() }
            .sheet(isPresented: $showProfiles) {
                ProfilesView()
            }
        }
        .fullScreenCover(isPresented: .init(
            get: { !acceptedDisclaimer },
            set: { _ in }
        )) {
            DisclaimerView { acceptedDisclaimer = true }
                .interactiveDismissDisabled()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(
                "",
                text: $query,
                prompt: Text("Advil, Calories, Sugar, etc.").foregroundColor(Color(.secondaryLabel))
            )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var results: some View {
        let found = store.search(query)
        if found.isEmpty {
            Text("No match yet. More substances are coming.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(found) { entry in
                    NavigationLink(value: entry) {
                        SubstanceRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
    }
}

struct SubstanceRow: View {
    let entry: BrowseEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name).font(.headline)
                Text(entry.hasData ? entry.category : "\(entry.category) · Coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
