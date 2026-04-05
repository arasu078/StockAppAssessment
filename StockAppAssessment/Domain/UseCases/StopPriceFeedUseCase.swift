import Foundation

public struct StopPriceFeedUseCase {
    private let repository: any StockRepository

    public init(repository: any StockRepository) {
        self.repository = repository
    }

    public func execute() async {
        await repository.stopPriceFeed()
    }
}
