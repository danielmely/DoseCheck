import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: SubstanceStore
    @EnvironmentObject private var profiles: ProfileStore
    @AppStorage("acceptedDisclaimer") private var acceptedDisclaimer: Bool = false
    @State private var query = ""
    @State private var showProfiles = false

    private var profile: Profile { profiles.active ?? .generic }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { showProfiles = true } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Results for").font(.caption).foregroundStyle(.secondary)
                            Text(profile.name).font(.headline)
                            Text(profile.summary).font(.footnote).foregroundStyle(.secondary)
                            if profile.isGeneric {
                                Text("Save your profile for numbers that fit you.")
                                    .font(.footnote)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Substances") {
                    let results = store.search(query)
                    if results.isEmpty {
                        Text("No match. More substances are coming.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(results) { s in
                        NavigationLink(value: s) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.name).font(.headline)
                                Text(s.category).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("DoseCheck")
            .searchable(text: $query, prompt: "Search coffee, salt, nutmeg…")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfiles = true } label: {
                        Label(profiles.active?.name ?? "Add person", systemImage: "person.crop.circle")
                            .labelStyle(.titleAndIcon)
                    }
                    .accessibilityLabel("Saved people")
                }
            }
            .navigationDestination(for: Substance.self) { s in
                SubstanceDetailView(substance: s, profile: profile)
            }
            .safeAreaInset(edge: .bottom) { SafetyFooter() }
            .sheet(isPresented: $showProfiles) {
                ProfilesView()
            }
        }
        .sheet(isPresented: .init(
            get: { !acceptedDisclaimer },
            set: { _ in }
        )) {
            DisclaimerView { acceptedDisclaimer = true }
                .interactiveDismissDisabled()
        }
    }
}

private struct DisclaimerView: View {
    var onAccept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before you start").font(.title.bold())
            Text("DoseCheck is an educational reference about how much of everyday things is too much. Figures are rough estimates, often from animal studies, and vary a lot between people. It is not medical advice.")
            Text("If someone may have swallowed something harmful, call Poison Control right away: 1-800-222-1222 (US).")
            Text("If you are having thoughts of harming yourself, call or text 988 (US) any time.")
            Spacer()
            Button("I understand") { onAccept() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
    }
}
