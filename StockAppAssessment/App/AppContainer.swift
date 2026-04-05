import Foundation

struct AppContainer {
    private let stockRepository: any StockRepository

    init(stockRepository: any StockRepository) {
        self.stockRepository = stockRepository
    }

    static func live() -> AppContainer {
        let repository = DefaultStockRepository(
            webSocketService: PostmanEchoWebSocketService(url: AppConstants.Networking.postmanEchoWebSocketURL),
            priceGenerator: RandomStockPriceGenerator(),
            seedQuotes: StockCatalog.defaultQuotes
        )

        return AppContainer(
            stockRepository: repository
        )
    }

    func makeSymbolsListViewModel() -> SymbolsListViewModel {
        SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: stockRepository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: stockRepository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: stockRepository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: stockRepository)
        )
    }
}
