import Foundation
import SwiftData

@Model
class Message {
    var id: UUID
    var text: String
    var isUser: Bool
    var timestamp: Date
    var feedback: Feedback?
    var starRating: Int?

    init(text: String, isUser: Bool, timestamp: Date = Date(), feedback: Feedback? = nil, starRating: Int? = nil) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.feedback = feedback
        self.starRating = starRating
    }
}

enum Feedback: String, Codable {
    case thumbsUp
    case thumbsDown
}
