import Foundation

struct AppContainer {
    private let stockRepository: any StockRepository

    init(stockRepository: any StockRepository) {
        self.stockRepository = stockRepository
    }

    static func live() -> AppContainer {
        let repository = DefaultStockRepository(
            webSocketService: PostmanEchoWebSocketService(url: AppConstants.Networking.postmanEchoWebSocketURL),
        )

        return AppContainer(
            stockRepository: repository
        )
    }

    func makeSymbolsListViewModel() -> SymbolsListViewModel {
        SymbolsListViewModel(
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: stockRepository),
        )
    }
}
