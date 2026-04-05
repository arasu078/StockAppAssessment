import Foundation

public struct StockUpdateMessageDTO: Codable, Sendable {
    public let updates: [StockPriceUpdateDTO]

    public init(updates: [StockPriceUpdateDTO]) {
        self.updates = updates
    }
}

public struct StockPriceUpdateDTO: Codable, Sendable {
    public let symbol: String
    public let price: Double

    public init(symbol: String, price: Double) {
        self.symbol = symbol
        self.price = price
    }
}
