import SwiftUI

struct SymbolDetailView: View {
    @StateObject private var viewModel: SymbolDetailViewModel

    init(symbol: String, container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: container.makeSymbolDetailViewModel(symbol: symbol)
        )
    }

    var body: some View {
        Group {
            if let stock = viewModel.stock {
                loadedContent(for: stock)
            } else {
                loadingState
            }
        }
    }

    private var loadingState: some View {
        ProgressView()
    }

    private func loadedContent(for stock: StockQuote) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stockIdentitySection(for: stock)
                priceCard(for: stock)
                descriptionSection(for: stock)
            }
            .padding(20)
        }
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stockIdentitySection(for stock: StockQuote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stock.symbol)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text(stock.companyName)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private func priceCard(for stock: StockQuote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stock.currentPrice.formatted(.currency(code: "USD")))
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .monospacedDigit()
            PriceChangeBadge(quote: stock)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private func descriptionSection(for stock: StockQuote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("detail_description_title")
                .font(.headline)
            Text(stock.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
