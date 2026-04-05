import Foundation

public protocol StockPriceGenerating: Sendable {
    func makeUpdates(for quotes: [StockQuote]) -> StockUpdateMessageDTO
}

public struct RandomStockPriceGenerator: StockPriceGenerating {
    public init() {}

    public func makeUpdates(for quotes: [StockQuote]) -> StockUpdateMessageDTO {
        StockUpdateMessageDTO(
            updates: quotes.map { quote in
                let delta = Double.random(in: -1.0 ... 1.0)
                let nextPrice = max(25, quote.currentPrice + delta)

                return StockPriceUpdateDTO(
                    symbol: quote.symbol,
                    price: nextPrice
                )
            }
        )
    }
}
