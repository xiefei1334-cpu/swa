public actor InMemoryItemStore: ItemStore {
    private var items: [Item]

    public init(items: [Item] = []) {
        self.items = items
    }

    public func allItems() -> [Item] {
        items
    }

    public func add(_ item: Item) {
        items.append(item)
    }
}
