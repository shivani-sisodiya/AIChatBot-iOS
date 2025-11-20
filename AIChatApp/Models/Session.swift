import Foundation
import SwiftData

@Model
class Session {
    var id: UUID
    var title: String
    var date: Date
    @Relationship(deleteRule: .cascade) var messages: [Message] = []

    init(title: String, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.date = date
    }
}
