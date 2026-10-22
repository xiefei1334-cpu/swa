import Observation
import SwACore

@MainActor
@Observable
final class HomeViewModel {
    var draftTitle = ""
    private(set) var state: HomeState?
    private(set) var errorMessage: String?

    private let homeModel: HomeModel

    init(homeModel: HomeModel) {
        self.homeModel = homeModel
    }

    var canAddItem: Bool {
        homeModel.canAddItem(title: draftTitle)
    }

    func load() async {
        do {
            state = try await homeModel.load()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addItem() async {
        let title = draftTitle
        guard homeModel.canAddItem(title: title) else { return }
        draftTitle = ""
        do {
            try await homeModel.addItem(title: title)
        } catch {
            draftTitle = title
            errorMessage = error.localizedDescription
            return
        }
        await load()
    }
}
