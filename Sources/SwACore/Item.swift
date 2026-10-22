import Foundation

public struct Item: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let createdAt: Date

    public init(id: UUID = UUID(), title: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}
