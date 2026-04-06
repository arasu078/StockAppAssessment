import Foundation
import Testing
import StockAppAssessment

@MainActor
struct UseCaseTests {
    @Test
    func observeUseCasesExposeRepositoryStreams() async {
        let repository = MockStockRepository(
            initialStocks: [makeQuote(symbol: "AAA", price: 100)],
            initialConnectionStatus: .connected
        )

        var stockIterator = ObserveStocksUseCase(repository: repository).execute().makeAsyncIterator()
        var statusIterator = ObserveConnectionStatusUseCase(repository: repository).execute().makeAsyncIterator()

        let stocks = await stockIterator.next()
        let status = await statusIterator.next()

        #expect(stocks?.count == 1)
        #expect(status == .connected)
    }

    @Test
    func startAndStopUseCasesForwardCommandsToRepository() async {
        let repository = MockStockRepository()

        await StartPriceFeedUseCase(repository: repository).execute()
        await StopPriceFeedUseCase(repository: repository).execute()

        #expect(repository.startCallCount == 1)
        #expect(repository.stopCallCount == 1)
    }
}
