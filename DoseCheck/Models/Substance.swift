import Foundation

/// One entry in the bundled toxicity reference.
/// All figures are estimates. Medications intentionally carry no toxic/lethal
/// numbers: the app shows only label guidance and Poison Control for them.
///
/// Every edible entry answers three questions: safe daily intake, toxicity
/// reported, and fatal dose. When there is no reliable number, the matching
/// `*Note` field explains why instead of leaving the row blank.
struct Substance: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let aliases: [String]
    let isMedication: Bool

    /// Dose (mg per kg body weight) where significant toxicity is reported.
    let toxicMgPerKg: Double?
    /// Estimated potentially lethal dose (mg per kg). nil = no established figure.
    let lethalMgPerKg: Double?
    /// Where the lethal figure comes from, e.g. "human estimate" or "rat LD50".
    let lethalBasis: String?

    /// Everyday adult guidance limit per day, in mg (used when not sex-specific).
    let guidanceDailyLimitMg: Double?
    let guidanceMaleMg: Double?
    let guidanceFemaleMg: Double?

    /// Shown when a figure is missing.
    let safeNote: String?
    let toxicNote: String?
    let lethalNote: String?

    /// Extra calculations, e.g. "bac" for the blood alcohol estimate.
    let extras: [String]?

    let servingName: String
    let servingMg: Double
    let notes: String
    let sources: [String]
    /// False until the figures are checked against the primary sources.
    let verified: Bool

    var hasSexSpecificLimit: Bool {
        guidanceMaleMg != nil || guidanceFemaleMg != nil
    }

    /// Daily limit for a person. For "other", uses the lower of the two limits.
    func dailyLimitMg(for gender: Gender) -> Double? {
        let male = guidanceMaleMg ?? guidanceDailyLimitMg
        let female = guidanceFemaleMg ?? guidanceDailyLimitMg
        switch gender {
        case .male: return male
        case .female: return female
        case .other: return [male, female].compactMap { $0 }.min()
        }
    }
}
