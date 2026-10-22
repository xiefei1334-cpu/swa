public protocol ItemStore: Sendable {
    func allItems() async throws -> [Item]
    func add(_ item: Item) async throws
}
