import Foundation

/// A name in the browse catalog that has no figures yet.
struct CatalogItem: Codable, Hashable {
    let id: String
    let name: String
    let category: String
}

/// One row in search and Browse. Either a full substance with figures,
/// or a catalog item whose figures are still being checked.
struct BrowseEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let substance: Substance?

    var hasData: Bool { substance != nil }
}
