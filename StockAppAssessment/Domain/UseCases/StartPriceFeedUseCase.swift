import Foundation

public struct StartPriceFeedUseCase {
    private let repository: any StockRepository

    public init(repository: any StockRepository) {
        self.repository = repository
    }

    public func execute() async {
        await repository.startPriceFeed()
    }
}
