import SwiftUI

struct PoisonControlButton: View {
    var body: some View {
        Link(destination: URL(string: "tel:18002221222")!) {
            Label("Poison Control: 1-800-222-1222", systemImage: "phone.fill")
                .foregroundStyle(.red)
        }
    }
}

/// Always-visible strip with emergency contacts.
struct SafetyFooter: View {
    var body: some View {
        HStack(spacing: 16) {
            Link(destination: URL(string: "tel:18002221222")!) {
                Label("Poison Control", systemImage: "phone.fill")
            }
            Link(destination: URL(string: "tel:988")!) {
                Label("988 Crisis Line", systemImage: "heart.fill")
            }
        }
        .font(.footnote.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
