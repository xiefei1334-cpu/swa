import SwiftUI

struct RootView: View {
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            HomeView(viewModel: dependencies.makeHomeViewModel())
        }
    }
}
