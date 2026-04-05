import SwiftUI

struct SymbolsListView: View {
    @ObservedObject var viewModel: SymbolsListViewModel
    let container: AppContainer

    var body: some View {
        NavigationStack {
            contentList
            .navigationTitle("stocks_title")
            .alert(item: $viewModel.activeAlert, content: makeAlert)
            .toolbar(content: toolbarContent)
        }
    }

    private var contentList: some View {
        List {
            connectionSection
            stocksSection
        }
    }

    private var connectionSection: some View {
        Section {
            connectionHeader
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
    
    private var stocksSection: some View {
        Section("stocks_title") {
            ForEach(viewModel.stocks) { stock in
                stockNavigationLink(for: stock)
            }
        }
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

    @ViewBuilder
    private func stockNavigationLink(for stock: StockQuote) -> some View {
        NavigationLink {
            SymbolDetailView(symbol: stock.symbol, container: container)
        } label: {
            StockRowView(quote: stock)
        }
    }

    private func makeAlert(for alert: StockFeedAlert) -> Alert {
        Alert(
            title: Text(String(localized: alert.title)),
            message: Text(String(localized: alert.message)),
            dismissButton: .default(Text(String(localized: alert.buttonTitle)))
        )
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            sortMenu
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("sort_title", selection: $viewModel.sortOption) {
                ForEach(StockSortOption.allCases) { option in
                    Text(option.localizedTitleKey)
                        .tag(option)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
    }
}
