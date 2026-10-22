import Foundation
import SwACore
import Testing

struct HomeModelTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func loadReturnsEmptyStateWhenStoreHasNoItems() async throws {
        let model = HomeModel(store: InMemoryItemStore(), dateProvider: FixedDateProvider(now))

        #expect(try await model.load() == .empty)
    }

    @Test func addItemStoresTrimmedTitleStampedWithCurrentDate() async throws {
        let store = InMemoryItemStore()
        let model = HomeModel(store: store, dateProvider: FixedDateProvider(now))

        let item = try await model.addItem(title: "  Buy milk \n")

        #expect(item.title == "Buy milk")
        #expect(item.createdAt == now)
        #expect(await store.allItems() == [item])
    }

    @Test func addedItemAppearsInLoadedState() async throws {
        let model = HomeModel(store: InMemoryItemStore(), dateProvider: FixedDateProvider(now))

        let item = try await model.addItem(title: "Walk the dog")

        #expect(try await model.load() == .items([item]))
    }

    @Test func loadListsItemsNewestFirst() async throws {
        let older = Item(title: "Older", createdAt: now.addingTimeInterval(-60))
        let newer = Item(title: "Newer", createdAt: now)
        let model = HomeModel(
            store: InMemoryItemStore(items: [older, newer]),
            dateProvider: FixedDateProvider(now)
        )

        #expect(try await model.load() == .items([newer, older]))
    }

    @Test(arguments: ["", "   ", "\n\t "])
    func addItemRejectsBlankTitle(_ title: String) async throws {
        let store = InMemoryItemStore()
        let model = HomeModel(store: store, dateProvider: FixedDateProvider(now))

        #expect(!model.canAddItem(title: title))
        await #expect(throws: HomeModelError.emptyTitle) {
            try await model.addItem(title: title)
        }
        #expect(await store.allItems().isEmpty)
        #expect(try await model.load() == .empty)
    }
}
