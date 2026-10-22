import Foundation
import SwACore
import Testing

struct InMemoryItemStoreTests {
    @Test func startsEmpty() async {
        let store = InMemoryItemStore()

        #expect(await store.allItems().isEmpty)
    }

    @Test func listsAddedItemsInInsertionOrder() async {
        let store = InMemoryItemStore()
        let first = Item(title: "First", createdAt: Date(timeIntervalSince1970: 1))
        let second = Item(title: "Second", createdAt: Date(timeIntervalSince1970: 2))

        await store.add(first)
        await store.add(second)

        #expect(await store.allItems() == [first, second])
    }

    @Test func listsSeededItems() async {
        let seeded = Item(title: "Seeded", createdAt: Date(timeIntervalSince1970: 0))
        let store = InMemoryItemStore(items: [seeded])

        #expect(await store.allItems() == [seeded])
    }
}
