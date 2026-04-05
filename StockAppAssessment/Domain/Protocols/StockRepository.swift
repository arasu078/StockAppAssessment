import Foundation

@MainActor
public protocol StockRepository: Sendable {
    func observeConnectionStatus() -> AsyncStream<ConnectionStatus>
}
