import SwACore

struct AppDependencies {
    let itemStore: any ItemStore
    let dateProvider: any DateProvider

    static func live() -> AppDependencies {
        AppDependencies(
            itemStore: InMemoryItemStore(),
            dateProvider: SystemDateProvider()
        )
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(homeModel: HomeModel(store: itemStore, dateProvider: dateProvider))
    }
}
