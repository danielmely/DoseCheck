import SwiftUI

/// Tapping opens the iPhone call prompt for the number.
private struct CallButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let number: String
    let tint: Color

    var body: some View {
        Link(destination: URL(string: "tel:\(number)")!) {
            VStack(spacing: 2) {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

struct PoisonControlButton: View {
    var body: some View {
        Link(destination: URL(string: "tel:18002221222")!) {
            Label("Poison Control: 1-800-222-1222", systemImage: "phone.fill")
                .foregroundStyle(.red)
        }
    }
}

/// Always-visible bar with the two emergency call buttons.
struct SafetyFooter: View {
    var body: some View {
        HStack(spacing: 10) {
            CallButton(
                title: "Poison Control",
                subtitle: "1-800-222-1222",
                icon: "phone.fill",
                number: "18002221222",
                tint: .red
            )
            CallButton(
                title: "Suicide & Crisis Lifeline",
                subtitle: "Call 988",
                icon: "heart.fill",
                number: "988",
                tint: .blue
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
