import Foundation

enum StoryLength: String, Codable, CaseIterable, Identifiable {
    case short, medium, long
    var id: String { rawValue }
}

struct StoryOptions: Codable, Equatable {
    var length: StoryLength
    var theme: String
    var characters: [String]
}
