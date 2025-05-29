import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var age: Int
    var interests: [String]
    var storyTime: Date
}
