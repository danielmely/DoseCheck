import SwiftUI

@main
struct DoseCheckApp: App {
    @StateObject private var store = SubstanceStore()
    @StateObject private var profiles = ProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(profiles)
        }
    }
}
