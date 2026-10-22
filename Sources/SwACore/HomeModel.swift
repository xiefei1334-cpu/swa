import Foundation

public enum HomeState: Equatable, Sendable {
    case empty
    case items([Item])
}

public enum HomeModelError: Error, Equatable, Sendable {
    case emptyTitle
}

public struct HomeModel: Sendable {
    private let store: any ItemStore
    private let dateProvider: any DateProvider

    public init(store: any ItemStore, dateProvider: any DateProvider) {
        self.store = store
        self.dateProvider = dateProvider
    }

    public func load() async throws -> HomeState {
        let items = try await store.allItems()
        guard !items.isEmpty else { return .empty }
        return .items(items.sorted { $0.createdAt > $1.createdAt })
    }

    public func canAddItem(title: String) -> Bool {
        Self.normalizedTitle(title) != nil
    }

    @discardableResult
    public func addItem(title: String) async throws -> Item {
        guard let title = Self.normalizedTitle(title) else {
            throw HomeModelError.emptyTitle
        }
        let item = Item(title: title, createdAt: dateProvider.now())
        try await store.add(item)
        return item
    }

    private static func normalizedTitle(_ title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
