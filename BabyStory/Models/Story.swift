import Foundation

struct Story: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var isFavorite: Bool
}
