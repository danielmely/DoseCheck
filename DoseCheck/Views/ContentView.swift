import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: SubstanceStore
    @AppStorage("weightKg") private var weightKg: Double = 70
    @AppStorage("useMetric") private var useMetric: Bool = false
    @AppStorage("acceptedDisclaimer") private var acceptedDisclaimer: Bool = false
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Your body weight") {
                    WeightRow(weightKg: $weightKg, useMetric: $useMetric)
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
            .navigationDestination(for: Substance.self) { s in
                SubstanceDetailView(substance: s, weightKg: weightKg)
            }
            .safeAreaInset(edge: .bottom) { SafetyFooter() }
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

private struct WeightRow: View {
    @Binding var weightKg: Double
    @Binding var useMetric: Bool

    private var displayValue: Binding<Double> {
        Binding(
            get: { useMetric ? weightKg : weightKg * 2.20462 },
            set: { weightKg = useMetric ? $0 : $0 / 2.20462 }
        )
    }

    var body: some View {
        HStack {
            TextField("Weight", value: displayValue, format: .number.precision(.fractionLength(0...1)))
                .keyboardType(.decimalPad)
                .frame(maxWidth: 100)
            Picker("Unit", selection: $useMetric) {
                Text("lb").tag(false)
                Text("kg").tag(true)
            }
            .pickerStyle(.segmented)
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
