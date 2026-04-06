import Foundation
import Testing
import StockAppAssessment

private actor RepositoryUpdateProbe {
    private(set) var stocks: [StockQuote]?

    func record(_ stocks: [StockQuote]) {
        self.stocks = stocks
    }
}

@MainActor
struct DefaultStockRepositoryTests {
    @Test
    func observeStocksEmitsSeedSnapshotImmediately() async {
        let repository = StockAppAssessment.DefaultStockRepository(
            webSocketService: MockStockWebSocketService(),
            priceGenerator: FixedStockPriceGenerator(delta: 5),
            seedQuotes: [
                makeQuote(symbol: "AAA", price: 100),
                makeQuote(symbol: "BBB", price: 200)
            ],
            updateInterval: Duration.milliseconds(10)
        )

        var iterator = repository.observeStocks().makeAsyncIterator()
        let initial = await iterator.next()

        #expect(initial?.count == 2)
    }

    @Test
    func startPriceFeedConnectsAndAppliesEchoedBatch() async throws {
        let socket = MockStockWebSocketService(autoEcho: true)
        let seedQuotes = makeQuotes(count: 12)
        let probe = RepositoryUpdateProbe()
        let repository = StockAppAssessment.DefaultStockRepository(
            webSocketService: socket,
            priceGenerator: FixedStockPriceGenerator(delta: 10),
            seedQuotes: seedQuotes,
            updateInterval: Duration.milliseconds(10)
        )

        var stockIterator = repository.observeStocks().makeAsyncIterator()
        _ = await stockIterator.next()

        Task {
            while let stocks = await stockIterator.next() {
                if stocks.contains(where: { $0.priceChange == 10 }) {
                    await probe.record(stocks)
                    break
                }
            }
        }

        await repository.startPriceFeed()

        await waitUntil {
            let updatedStocks = await probe.stocks
            let hasSentMessages = await MainActor.run {
                !socket.sentMessages.isEmpty
            }
            return hasSentMessages && updatedStocks != nil
        }

        let updatedStocks = await probe.stocks
        #expect(updatedStocks != nil)
        #expect(updatedStocks?.contains(where: { $0.priceChange == 10 }) == true)

        let payload = try #require(socket.sentMessages.first)
        let message = try JSONDecoder().decode(StockAppAssessment.StockUpdateMessageDTO.self, from: Data(payload.utf8))
        #expect(message.updates.count >= 10)
        #expect(message.updates.count <= seedQuotes.count)
        #expect(Set(message.updates.map(\.symbol)).count == message.updates.count)

        if let updatedStocks {
            for stock in updatedStocks where message.updates.contains(where: { $0.symbol == stock.symbol }) {
                #expect(stock.priceChange == 10)
            }
        }
        #expect(socket.connectCallCount == 1)

        await repository.stopPriceFeed()
    }

    @Test
    func stopPriceFeedDisconnectsAndPublishesDisconnectedStatus() async {
        let socket = MockStockWebSocketService(autoEcho: false)
        let repository = StockAppAssessment.DefaultStockRepository(
            webSocketService: socket,
            priceGenerator: FixedStockPriceGenerator(delta: 10),
            seedQuotes: makeQuotes(count: 12),
            updateInterval: Duration.milliseconds(10)
        )

        var iterator = repository.observeConnectionStatus().makeAsyncIterator()
        _ = await iterator.next()

        await repository.startPriceFeed()
        _ = await iterator.next()
        await repository.stopPriceFeed()
        let finalStatus = await iterator.next()

        #expect(socket.disconnectCallCount == 1)
        #expect(finalStatus == .disconnected)
    }
}
