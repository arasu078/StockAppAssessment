import Foundation

public enum StockCatalog {
    public static let defaultQuotes: [StockQuote] = [
        make("NVDA", "NVIDIA", 902.12),
        make("AAPL", "Apple", 196.45),
        make("GOOG", "Alphabet Class C", 171.80),
        make("MSFT", "Microsoft", 428.13),
        make("AMZN", "Amazon", 185.62),
        make("META", "Meta Platforms", 498.02),
        make("TSLA", "Tesla", 177.34),
        make("AMD", "Advanced Micro Devices", 164.19),
        make("NFLX", "Netflix", 641.55),
        make("AVGO", "Broadcom", 1386.43),
        make("ORCL", "Oracle", 127.91),
        make("CRM", "Salesforce", 295.47),
        make("INTC", "Intel", 39.74),
        make("ADBE", "Adobe", 497.18),
        make("QCOM", "Qualcomm", 170.88),
        make("SHOP", "Shopify", 75.12),
        make("UBER", "Uber", 78.44),
        make("SNOW", "Snowflake", 158.30),
        make("PYPL", "PayPal", 63.52),
        make("PLTR", "Palantir", 25.61),
        make("ASML", "ASML Holding", 944.11),
        make("ARM", "Arm Holdings", 122.45),
        make("MU", "Micron Technology", 114.23),
        make("SAP", "SAP", 191.04),
        make("IBM", "IBM", 188.36)
    ]

    private static func make(
        _ symbol: String,
        _ companyName: String,
        _ price: Double
    ) -> StockQuote {
        guard let descriptionKey = StockDescriptionKey(symbol: symbol) else {
            preconditionFailure("Missing description key for stock symbol \(symbol)")
        }

        return StockQuote(
            symbol: symbol,
            companyName: companyName,
            descriptionKey: descriptionKey,
            currentPrice: price,
            priceChange: 0
        )
    }
}
