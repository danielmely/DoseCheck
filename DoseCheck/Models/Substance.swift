import Foundation

/// One entry in the bundled toxicity reference.
/// All figures are estimates. Medications intentionally carry no toxic/lethal
/// numbers: the app shows only label guidance and Poison Control for them.
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
    /// Everyday adult guidance limit per day, in mg.
    let guidanceDailyLimitMg: Double?
    let servingName: String
    let servingMg: Double
    let notes: String
    let sources: [String]
    /// False until the figures are checked against the primary sources.
    let verified: Bool
}
