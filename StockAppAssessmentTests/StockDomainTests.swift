import Foundation
import Testing
import StockAppAssessment

struct StockDomainTests {
    @Test
    func stockTrendReflectsPriceChange() {
        #expect(makeQuote(symbol: "UP", price: 10, change: 2).trend == .up)
        #expect(makeQuote(symbol: "DOWN", price: 10, change: -2).trend == .down)
        #expect(makeQuote(symbol: "FLAT", price: 10, change: 0).trend == .flat)
    }

    @Test
    func stockCatalogProvidesTwentyFiveUniqueQuotes() {
        let quotes = StockCatalog.defaultQuotes

        #expect(quotes.count == 25)
        #expect(Set(quotes.map(\.symbol)).count == 25)
    }

    @Test
    func localizedDescriptionKeyMapsToStringCatalogEntries() {
        let value = String(localized: StockDescriptionKey.nvda.localizedStringResource)

        #expect(!value.isEmpty)
    }

    @Test
    func stockCatalogDescriptionKeysMatchSymbols() {
        let quotes = StockCatalog.defaultQuotes

        #expect(
            quotes.allSatisfy { quote in
                quote.descriptionKey.rawValue == quote.symbol.lowercased()
            }
        )
    }

    @Test
    func connectionLostAlertGeneratesFreshIdentityPerEmission() {
        let first = StockFeedAlert.connectionLost
        let second = StockFeedAlert.connectionLost

        #expect(first.id != second.id)
        #expect(first.kind == second.kind)
        #expect(first.title == second.title)
        #expect(first.message == second.message)
        #expect(first.buttonTitle == second.buttonTitle)
    }
}
