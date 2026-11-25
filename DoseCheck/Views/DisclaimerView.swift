import SwiftUI

/// Start-up warning shown every time the app opens fresh.
/// The user must scroll to the very end. The accept button stays grey until
/// they have reached the end AND a 5-second countdown has finished, so
/// scrolling straight to the bottom does not skip the reading time.
struct DisclaimerView: View {
    var onAccept: () -> Void

    private static let countdownSeconds = 5

    @State private var secondsLeft = DisclaimerView.countdownSeconds
    @State private var reachedBottom = false
    @State private var timer: Timer?

    private var canAccept: Bool { reachedBottom && secondsLeft == 0 }

    private var buttonTitle: String {
        if !reachedBottom { return "Scroll to the end to continue" }
        if secondsLeft > 0 { return "Accept and continue (\(secondsLeft))" }
        return "Accept and continue"
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(spacing: 0) {
                    content
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .frame(minHeight: geo.size.height * 1.4, alignment: .top)

                    Button {
                        onAccept()
                    } label: {
                        Text(buttonTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canAccept)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .onAppear { reachedBottom = true }
                }
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear { timer?.invalidate() }
    }

    private var content: some View {
        VStack(spacing: 56) {
            Text("⚠️ READ BEFORE CONTINUING ⚠️")
                .font(.title2.weight(.heavy))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            (Text("This app ") + Text("IS NOT").underline() + Text(" any sort of medical advice."))
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            left(Text("DoseCheck").italic().bold()
                 + Text(" is an ")
                 + Text("EDUCATIONAL REFERENCE ONLY,").bold()
                 + Text(" and about how much of everyday things could possibly become too much."))

            left(Text("All figures and data are ")
                 + Text("rough estimates,").italic()
                 + Text(" often from animal studies and vary a lot between people. Never rely on this app if you even ")
                 + Text("SUSPECT").bold()
                 + Text(" someone may have ingested, inhaled or taken in any manner something ")
                 + Text("POTENTIALLY").bold()
                 + Text(" hazardous."))

            leftAttr(callText(
                intro: "If someone may have swallowed something harmful, close this app and IMMEDIATELY\nCall ",
                label: "Poison Control",
                number: "1-800-222-1222 (US).",
                url: "tel:18002221222"))

            leftAttr(callText(
                intro: "Additionally, if YOU or ANYONE you know are having thoughts of harming yourself, themself or others, close this app and IMMEDIATELY\nCALL or TEXT the ",
                label: "Suicide Hotline",
                number: "988 (US).",
                url: "tel:988"))

            left(Text("By continuing below the user understands and accepts they personally are responsible for any and all past, present and future risk and liability.").italic())

            Text("Keep scrolling to continue ↓")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .font(.title3)
    }

    private func left(_ text: Text) -> some View {
        text
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Bold paragraph whose label and phone number are tappable and open the iPhone call prompt.
    private func callText(intro: String, label: String, number: String, url: String) -> AttributedString {
        let link = URL(string: url)
        var out = AttributedString(intro)
        var l = AttributedString(label)
        l.underlineStyle = .single
        l.link = link
        let colon = AttributedString(":\n")
        var n = AttributedString(number)
        n.underlineStyle = .single
        n.link = link
        out.append(l); out.append(colon); out.append(n)
        out.font = .title3.bold()
        return out
    }

    private func leftAttr(_ text: AttributedString) -> some View {
        Text(text)
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func startTimer() {
        secondsLeft = Self.countdownSeconds
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if secondsLeft > 0 { secondsLeft -= 1 }
            if secondsLeft == 0 { t.invalidate() }
        }
    }
}
