import Foundation
import Testing
import StockAppAssessment

struct RandomStockPriceGeneratorTests {
    @Test
    func makeUpdatesPreservesBatchSizeAndSymbols() {
        let generator = RandomStockPriceGenerator()
        let quotes = [
            makeQuote(symbol: "AAA", price: 100),
            makeQuote(symbol: "BBB", price: 200),
            makeQuote(symbol: "CCC", price: 300)
        ]

        let updates = generator.makeUpdates(for: quotes)

        #expect(updates.updates.count == quotes.count)
        #expect(Set(updates.updates.map(\.symbol)) == Set(quotes.map(\.symbol)))
    }

    @Test
    func makeUpdatesNeverDropsBelowMinimumPriceFloor() {
        let generator = RandomStockPriceGenerator()
        let quotes = [makeQuote(symbol: "LOW", price: 1)]

        let updates = generator.makeUpdates(for: quotes)

        #expect(updates.updates.first?.price ?? 0 >= 25)
    }
}
