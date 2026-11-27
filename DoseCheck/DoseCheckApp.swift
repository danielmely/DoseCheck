import SwiftUI

@main
struct DoseCheckApp: App {
    @StateObject private var store = SubstanceStore()
    @StateObject private var profiles = ProfileStore()
    /// Dark mode is the default. Day mode is switched on from the Saved people screen.
    @AppStorage("dayMode") private var dayMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(profiles)
                .preferredColorScheme(dayMode ? .light : .dark)
        }
    }
}
