import SwiftUI

/// Sheet listing saved people. Tap one to use it; swipe to edit or delete.
struct ProfilesView: View {
    @EnvironmentObject private var profiles: ProfileStore
    @Environment(\.dismiss) private var dismiss
    @State private var adding = false
    @State private var editing: Profile?
    @AppStorage("dayMode") private var dayMode = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $dayMode) {
                        Label("Day mode", systemImage: "sun.max.fill")
                    }
                } footer: {
                    Text("DoseCheck uses dark mode by default. Turn on day mode for a light screen.")
                }

                if profiles.profiles.isEmpty {
                    Section {
                        Text("No saved people yet. Add yourself to get numbers that fit your body.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    ForEach(profiles.profiles) { p in
                        Button {
                            profiles.activeID = p.id
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.name).font(.headline)
                                    Text(p.summary).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if p.id == profiles.active?.id {
                                    Image(systemName: "checkmark").foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button("Delete", role: .destructive) { profiles.delete(p) }
                            Button("Edit") { editing = p }.tint(.orange)
                        }
                    }
                } footer: {
                    Text("Weight scales the toxic and fatal doses. Gender at birth picks sex-specific guidance. Height, weight and gender at birth together estimate body water for the alcohol estimate. Saved on this device only.")
                }
            }
            .navigationTitle("Saved people")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { adding = true } label: {
                        Label("Add person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $adding) {
                ProfileEditView(existing: nil)
            }
            .sheet(item: $editing) { p in
                ProfileEditView(existing: p)
            }
        }
    }
}

struct ProfileEditView: View {
    @EnvironmentObject private var profiles: ProfileStore
    @Environment(\.dismiss) private var dismiss

    let existing: Profile?

    @State private var name = ""
    @State private var gender: Gender = .other
    @State private var useMetric = false
    @State private var weightText = ""
    @State private var cmText = ""
    @State private var feetText = ""
    @State private var inchesText = ""

    init(existing: Profile?) {
        self.existing = existing
        guard let p = existing else { return }
        _name = State(initialValue: p.name)
        _gender = State(initialValue: p.gender)
        _useMetric = State(initialValue: p.useMetric)
        _weightText = State(initialValue: Self.fmt(p.useMetric ? p.weightKg : p.weightKg * 2.20462))
        _cmText = State(initialValue: Self.fmt(p.heightCm))
        let (ft, inch) = Profile.feetAndInches(fromCm: p.heightCm)
        _feetText = State(initialValue: String(ft))
        _inchesText = State(initialValue: String(inch))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Gender at birth") {
                    Picker("Gender at birth", selection: $gender) {
                        ForEach(Gender.allCases) { Text($0.label).tag($0) }
                    }
                }

                Section("Preferred units") {
                    Picker("Units", selection: $useMetric) {
                        Text("lb, ft/in").tag(false)
                        Text("kg, cm").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Body") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField(useMetric ? "kg" : "lb", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(useMetric ? "kg" : "lb").foregroundStyle(.secondary)
                    }
                    if useMetric {
                        HStack {
                            Text("Height")
                            Spacer()
                            TextField("cm", text: $cmText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("cm").foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Height")
                            Spacer()
                            TextField("ft", text: $feetText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                            Text("ft").foregroundStyle(.secondary)
                            TextField("in", text: $inchesText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 44)
                            Text("in").foregroundStyle(.secondary)
                        }
                    }
                }

                if let draft = draftProfile() {
                    Section {
                        Text(String(format: "BMI %.1f", draft.bmi))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section {
                        Text("Enter a name, a weight between 44 and 880 lb (20 to 400 kg) and a height between 3 and 8 ft (90 to 250 cm).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(existing == nil ? "Add person" : "Edit person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let p = draftProfile() {
                            profiles.save(p)
                            dismiss()
                        }
                    }
                    .disabled(draftProfile() == nil)
                }
            }
            .onChange(of: useMetric) { old, new in
                convertFields(from: old, to: new)
            }
        }
    }

    // MARK: - Helpers

    private static func fmt(_ v: Double) -> String {
        String(format: "%.1f", v).replacingOccurrences(of: ".0", with: "")
    }

    private static func parse(_ s: String) -> Double? {
        Double(s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }

    /// Current form values in kg and cm, or nil if anything is missing or out of range.
    private func draftProfile() -> Profile? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let w = Self.parse(weightText) else { return nil }
        let weightKg = useMetric ? w : w / 2.20462
        let heightCm: Double
        if useMetric {
            guard let cm = Self.parse(cmText) else { return nil }
            heightCm = cm
        } else {
            guard let ft = Self.parse(feetText) else { return nil }
            let inch = Self.parse(inchesText) ?? 0
            heightCm = (ft * 12 + inch) * 2.54
        }
        guard (20...400).contains(weightKg), (90...250).contains(heightCm) else { return nil }
        return Profile(
            id: existing?.id ?? UUID(),
            name: trimmed,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            useMetric: useMetric
        )
    }

    /// Keeps the numbers the same person when the unit toggle flips.
    private func convertFields(from old: Bool, to new: Bool) {
        if let w = Self.parse(weightText) {
            let kg = old ? w : w / 2.20462
            weightText = Self.fmt(new ? kg : kg * 2.20462)
        }
        let cm: Double?
        if old {
            cm = Self.parse(cmText)
        } else if let ft = Self.parse(feetText) {
            cm = (ft * 12 + (Self.parse(inchesText) ?? 0)) * 2.54
        } else {
            cm = nil
        }
        guard let cm else { return }
        if new {
            cmText = Self.fmt(cm)
        } else {
            let (ft, inch) = Profile.feetAndInches(fromCm: cm)
            feetText = String(ft)
            inchesText = String(inch)
        }
    }
}
