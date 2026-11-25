import Foundation

/// Saved people, stored on the device in UserDefaults.
@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profiles: [Profile] = []
    @Published var activeID: UUID? {
        didSet { UserDefaults.standard.set(activeID?.uuidString, forKey: Self.activeKey) }
    }

    private static let profilesKey = "profiles.v1"
    private static let activeKey = "activeProfileID.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.profilesKey),
           let saved = try? JSONDecoder().decode([Profile].self, from: data) {
            profiles = saved
        }
        if let raw = UserDefaults.standard.string(forKey: Self.activeKey) {
            activeID = UUID(uuidString: raw)
        }
    }

    /// The selected person, or the first saved one. nil when nobody is saved.
    var active: Profile? {
        profiles.first { $0.id == activeID } ?? profiles.first
    }

    func save(_ profile: Profile) {
        if let i = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[i] = profile
        } else {
            profiles.append(profile)
            activeID = profile.id
        }
        persist()
    }

    func delete(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        if activeID == profile.id { activeID = profiles.first?.id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: Self.profilesKey)
        }
    }
}
