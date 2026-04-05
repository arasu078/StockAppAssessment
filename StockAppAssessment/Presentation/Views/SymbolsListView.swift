import SwiftUI

struct SymbolsListView: View {
    @ObservedObject var viewModel: SymbolsListViewModel
    let container: AppContainer

    var body: some View {
        NavigationStack {
            contentList
            .navigationTitle("stocks_title")
        }
    }

    private var contentList: some View {
        List {
            connectionSection
        }
    }

    private var connectionSection: some View {
        Section {
            connectionHeader
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }

    private var connectionHeader: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(viewModel.connectionStatus.tint)
                .frame(width: 10, height: 10)

            Text(viewModel.connectionStatus.localizedTitleKey)
                .font(.subheadline.weight(.semibold))

            Spacer()

            Button(viewModel.isConnected ? "action_stop" : "action_start") {
                viewModel.toggleConnection()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
