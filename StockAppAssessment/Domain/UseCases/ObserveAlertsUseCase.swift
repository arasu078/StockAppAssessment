import Foundation

public struct ObserveAlertsUseCase {
    private let repository: any StockRepository

    public init(repository: any StockRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<StockFeedAlert> {
        repository.observeAlerts()
    }
}
