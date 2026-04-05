import Foundation

public struct StockQuote: Identifiable, Equatable, Hashable, Sendable {
    public let symbol: String
    public let companyName: String
    public let descriptionKey: StockDescriptionKey
    public var currentPrice: Double
    public var priceChange: Double

    public init(
        symbol: String,
        companyName: String,
        descriptionKey: StockDescriptionKey,
        currentPrice: Double,
        priceChange: Double
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.descriptionKey = descriptionKey
        self.currentPrice = currentPrice
        self.priceChange = priceChange
    }

    public var id: String { symbol }

    public var trend: StockTrend {
        if priceChange > 0 {
            return .up
        } else if priceChange < 0 {
            return .down
        } else {
            return .flat
        }
    }
}

public enum StockTrend: Sendable {
    case up
    case down
    case flat
}

public enum StockDescriptionKey: String, Sendable {
    case aapl
    case adbe
    case amd
    case amzn
    case arm
    case asml
    case avgo
    case crm
    case goog
    case ibm
    case intc
    case meta
    case msft
    case mu
    case nflx
    case nvda
    case orcl
    case pltr
    case pypl
    case qcom
    case sap
    case shop
    case snow
    case tsla
    case uber

    public init?(symbol: String) {
        self.init(rawValue: symbol.lowercased())
    }
}
