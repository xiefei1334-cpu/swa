import SwACore
import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) { composer }
            .navigationTitle("Home")
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case nil:
            ProgressView()
        case .empty:
            ContentUnavailableView(
                "No Items",
                systemImage: "tray",
                description: Text("Add your first item below.")
            )
        case .items(let items):
            List(items) { item in
                LabeledContent(item.title) {
                    Text(item.createdAt, style: .time)
                }
            }
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            HStack {
                TextField("New item", text: $viewModel.draftTitle)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit { submit() }
                Button("Add") { submit() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canAddItem)
            }
        }
        .padding()
        .background(.bar)
    }

    private func submit() {
        Task { await viewModel.addItem() }
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(homeModel: HomeModel(
            store: InMemoryItemStore(items: [Item(title: "Preview item", createdAt: .now)]),
            dateProvider: SystemDateProvider()
        )))
    }
}
