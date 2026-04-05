import SwiftUI

struct StockRowView: View {
    let quote: StockQuote

    var body: some View {
        HStack(spacing: 14) {
            quoteIdentity
            Spacer()
            quotePricing
        }
        .padding(.vertical, 6)
    }

    private var quoteIdentity: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.symbol)
                .font(.headline)
            Text(quote.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var quotePricing: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text(quote.currentPrice.formatted(.currency(code: "USD")))
                .font(.headline.monospacedDigit())
            PriceChangeBadge(quote: quote)
        }
    }
}
