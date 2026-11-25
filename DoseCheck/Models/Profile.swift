import Foundation

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male, female, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other / prefer not to say"
        }
    }
}

/// A saved person. Weight, height and gender all feed the numbers shown:
/// weight scales toxic and fatal doses, gender picks sex-specific guidance,
/// and height + weight + gender estimate body water for the alcohol estimate.
struct Profile: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var gender: Gender
    var heightCm: Double
    var weightKg: Double
    /// true = kg and cm, false = lb and ft/in.
    var useMetric: Bool

    static let genericID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    /// Used until the person saves a profile of their own.
    static let generic = Profile(
        id: genericID,
        name: "Average adult",
        gender: .other,
        heightCm: 170,
        weightKg: 70,
        useMetric: false
    )

    var isGeneric: Bool { id == Profile.genericID }

    var bmi: Double {
        let m = heightCm / 100
        return weightKg / (m * m)
    }

    /// Hume-Weyers total body water estimate in liters (adults).
    var totalBodyWaterL: Double {
        let male = 0.194786 * heightCm + 0.296785 * weightKg - 14.012934
        let female = 0.344547 * heightCm + 0.183809 * weightKg - 35.270121
        switch gender {
        case .male: return male
        case .female: return female
        case .other: return (male + female) / 2
        }
    }

    var weightText: String {
        useMetric
            ? String(format: "%.0f kg", weightKg)
            : String(format: "%.0f lb", weightKg * 2.20462)
    }

    var heightText: String {
        if useMetric { return String(format: "%.0f cm", heightCm) }
        let (ft, inch) = Profile.feetAndInches(fromCm: heightCm)
        return "\(ft)'\(inch)\""
    }

    var summary: String {
        isGeneric
            ? "\(weightText) · \(heightText)"
            : "\(weightText) · \(heightText) · \(gender.label)"
    }

    static func feetAndInches(fromCm cm: Double) -> (Int, Int) {
        let totalInches = cm / 2.54
        var ft = Int(totalInches / 12)
        var inch = Int((totalInches - Double(ft * 12)).rounded())
        if inch == 12 { ft += 1; inch = 0 }
        return (ft, inch)
    }
}
