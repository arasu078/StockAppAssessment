import SwiftUI

struct PriceChangeBadge: View {
    let quote: StockQuote

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
            Text(formattedChange)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var iconName: String {
        switch quote.trend {
        case .up:
            return "arrow.up.right"
        case .down:
            return "arrow.down.right"
        case .flat:
            return "minus"
        }
    }

    private var color: Color {
        switch quote.trend {
        case .up:
            return .green
        case .down:
            return .red
        case .flat:
            return .secondary
        }
    }

    private var formattedChange: String {
        quote.priceChange.formatted(.currency(code: "USD").precision(.fractionLength(2)))
    }
}
