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
            FooterLabel(title: title, subtitle: subtitle, icon: icon)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

private struct FooterLabel: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(spacing: 2) {
            Label(title, systemImage: icon)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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

/// Always-visible bar: suicide hotline (red) on the left, Poison Control (orange)
/// in the middle, sources (yellow) on the right.
struct SafetyFooter: View {
    @State private var showSources = false

    var body: some View {
        HStack(spacing: 8) {
            CallButton(
                title: "Suicide Hotline",
                subtitle: "Call 988",
                icon: "heart.fill",
                number: "988",
                tint: .red
            )
            CallButton(
                title: "Poison Control",
                subtitle: "1-800-222-1222",
                icon: "phone.fill",
                number: "18002221222",
                tint: .orange
            )
            Button { showSources = true } label: {
                FooterLabel(title: "Sources", subtitle: "Where data is from", icon: "book.fill")
                    .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .accessibilityLabel("Sources, where the data comes from")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showSources) { SourcesView() }
    }
}
