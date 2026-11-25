import SwiftUI

struct SubstanceDetailView: View {
    let substance: Substance
    let profile: Profile

    var body: some View {
        List {
            if !substance.verified {
                Section {
                    Label("Figures pending verification", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }

            personSection

            if let measured = substance.measuredAs {
                Section {
                    Label("Figures below are for the \(measured) in this item.", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if substance.isMedication {
                medicationSection
            } else {
                Section("Safe daily intake") { safeRow }
                Section("Toxicity reported") { toxicRow }
                Section("Fatal dose (estimate)") { fatalRow }
                if substance.extras?.contains("bac") == true {
                    bloodAlcoholSection
                }
            }

            Section("About") {
                Text(substance.notes)
            }

            if !substance.sources.isEmpty {
                Section("Sources") {
                    ForEach(substance.sources) { SourceLink(source: $0) }
                }
            }
        }
        .navigationTitle(substance.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { SafetyFooter() }
    }

    // MARK: - Sections

    private var personSection: some View {
        Section("Results for") {
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name).font(.headline)
                Text(profile.summary).font(.footnote).foregroundStyle(.secondary)
                if profile.isGeneric {
                    Text("Save your profile from the person button for numbers that fit you.")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    @ViewBuilder
    private var medicationSection: some View {
        Section("Label guidance") {
            if let limit = substance.guidanceDailyLimitMg {
                DoseRow(mg: limit, substance: substance, footnote: "Adult OTC label limit per day")
            }
            Text("Take only as directed and count every product that contains it. If someone took more than directed, call Poison Control now, even if they feel fine.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var safeRow: some View {
        if let perKg = substance.guidanceMgPerKg {
            DoseRow(
                mg: perKg * profile.weightKg,
                substance: substance,
                footnote: "Acceptable daily intake of \(Format.servings(perKg)) mg per kg, scaled to \(profile.weightText)"
            )
        } else if let mg = substance.dailyLimitMg(for: profile.gender) {
            DoseRow(mg: mg, substance: substance, footnote: limitFootnote)
        } else {
            NoteRow(text: substance.safeNote ?? "No established daily limit.")
        }
    }

    @ViewBuilder
    private var toxicRow: some View {
        if let perKg = substance.toxicMgPerKg {
            DoseRow(
                mg: perKg * profile.weightKg,
                substance: substance,
                footnote: "Scaled to \(profile.weightText)"
            )
        } else {
            NoteRow(text: substance.toxicNote ?? "No reliable figure.")
        }
    }

    @ViewBuilder
    private var fatalRow: some View {
        if let perKg = substance.lethalMgPerKg {
            DoseRow(
                mg: perKg * profile.weightKg,
                substance: substance,
                footnote: [substance.lethalBasis, "Scaled to \(profile.weightText)"]
                    .compactMap { $0 }
                    .joined(separator: ". ")
            )
        } else {
            NoteRow(text: substance.lethalNote ?? "No established fatal dose.")
        }
    }

    @ViewBuilder
    private var bloodAlcoholSection: some View {
        let tbw = profile.totalBodyWaterL
        if tbw > 10 {
            Section("Blood alcohol per drink") {
                // Peak estimate: blood is about 80.6% water, so
                // BAC (g/dL) = 0.806 x grams of alcohol / (body water in L x 10).
                let grams = substance.servingMg / 1000
                let bac = 0.806 * grams / (tbw * 10)
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "≈ %.3f%%", bac)).font(.title3.bold())
                    Text("Peak estimate for one standard drink, before your body clears any. Based on body water estimated from your height, weight and gender. Real values vary.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var limitFootnote: String? {
        guard substance.hasSexSpecificLimit else { return nil }
        switch profile.gender {
        case .male: return "Guidance for men"
        case .female: return "Guidance for women"
        case .other: return "Lower of the guidance for men and women"
        }
    }
}

private struct DoseRow: View {
    let mg: Double
    let substance: Substance
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Format.mass(mg)).font(.title3.bold())
            Text("≈ \(Format.servings(mg / substance.servingMg)) × \(substance.servingName)")
                .font(.footnote)
            if let footnote, !footnote.isEmpty {
                Text(footnote).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// A tappable source row. Falls back to plain text when there is no link.
struct SourceLink: View {
    let source: SourceRef

    var body: some View {
        if let text = source.url, let url = URL(string: text) {
            Link(destination: url) {
                HStack {
                    Text(source.title).font(.footnote).multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "arrow.up.right.square").foregroundStyle(.secondary)
                }
            }
        } else {
            Text(source.title).font(.footnote)
        }
    }
}

private struct NoteRow: View {
    let text: String

    var body: some View {
        Text(text).foregroundStyle(.secondary)
    }
}

enum Format {
    static func mass(_ mg: Double) -> String {
        if mg >= 1000 { return String(format: "%.1f g", mg / 1000) }
        if mg >= 10 { return String(format: "%.0f mg", mg) }
        if mg >= 1 { return String(format: "%.1f mg", mg) }
        return String(format: "%.0f µg", mg * 1000)
    }

    static func servings(_ n: Double) -> String {
        n < 10 ? String(format: "%.1f", n) : String(format: "%.0f", n)
    }
}
