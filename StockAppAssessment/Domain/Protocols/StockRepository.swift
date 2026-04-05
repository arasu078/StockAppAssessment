import Foundation

@MainActor
public protocol StockRepository: Sendable {
    func observeStocks() -> AsyncStream<[StockQuote]>
    func observeConnectionStatus() -> AsyncStream<ConnectionStatus>
    func observeAlerts() -> AsyncStream<StockFeedAlert>
    func startPriceFeed() async
    func stopPriceFeed() async
}
