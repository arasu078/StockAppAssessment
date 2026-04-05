import Foundation

public struct ObserveConnectionStatusUseCase {
    private let repository: any StockRepository

    public init(repository: any StockRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<ConnectionStatus> {
        repository.observeConnectionStatus()
    }
}
