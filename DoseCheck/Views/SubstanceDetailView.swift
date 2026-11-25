import SwiftUI

struct SubstanceDetailView: View {
    let substance: Substance
    let weightKg: Double

    var body: some View {
        List {
            if !substance.verified {
                Section {
                    Label("Figures pending verification", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }

            if substance.isMedication {
                medicationSection
            } else {
                thresholdsSection
            }

            Section("About") {
                Text(substance.notes)
            }

            if !substance.sources.isEmpty {
                Section("Sources") {
                    ForEach(substance.sources, id: \.self) { Text($0).font(.footnote) }
                }
            }

            Section {
                PoisonControlButton()
            }
        }
        .navigationTitle(substance.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { SafetyFooter() }
    }

    @ViewBuilder
    private var medicationSection: some View {
        Section("Label guidance") {
            if let limit = substance.guidanceDailyLimitMg {
                DoseRow(title: "Max per day (adult, OTC label)", mg: limit, substance: substance)
            }
            Text("Take only as directed and count every product that contains it. If someone took more than directed, call Poison Control now, even if they feel fine.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var thresholdsSection: some View {
        Section("For \(Format.weight(weightKg))") {
            if let limit = substance.guidanceDailyLimitMg {
                DoseRow(title: "Everyday guidance limit", mg: limit, substance: substance)
            }
            if let toxic = substance.toxicMgPerKg {
                DoseRow(title: "Toxic effects reported", mg: toxic * weightKg, substance: substance)
            }
            if let lethal = substance.lethalMgPerKg {
                DoseRow(
                    title: "Potentially lethal (estimate)",
                    mg: lethal * weightKg,
                    substance: substance,
                    footnote: substance.lethalBasis
                )
            } else {
                Text("No well-established lethal dose.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct DoseRow: View {
    let title: String
    let mg: Double
    let substance: Substance
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(Format.mass(mg)).font(.title3.bold())
            Text("≈ \(Format.servings(mg / substance.servingMg)) × \(substance.servingName)")
                .font(.footnote)
            if let footnote {
                Text("Basis: \(footnote)").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

enum Format {
    static func mass(_ mg: Double) -> String {
        mg >= 1000 ? String(format: "%.1f g", mg / 1000) : String(format: "%.0f mg", mg)
    }

    static func servings(_ n: Double) -> String {
        n < 10 ? String(format: "%.1f", n) : String(format: "%.0f", n)
    }

    static func weight(_ kg: Double) -> String {
        String(format: "%.0f kg (%.0f lb)", kg, kg * 2.20462)
    }
}
