import Foundation

public struct ObserveStocksUseCase {
    private let repository: any StockRepository

    public init(repository: any StockRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<[StockQuote]> {
        repository.observeStocks()
    }
}
