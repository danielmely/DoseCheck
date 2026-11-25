import SwiftUI

@main
struct DoseCheckApp: App {
    @StateObject private var store = SubstanceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
