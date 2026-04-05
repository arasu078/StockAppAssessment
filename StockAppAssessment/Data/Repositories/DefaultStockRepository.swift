import Foundation

@MainActor
public final class DefaultStockRepository: StockRepository {
    private let webSocketService: any StockWebSocketService
    private var senderTask: Task<Void, Never>?
    private var receiverTask: Task<Void, Never>?
    
    private var statusContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]
    private var connectionStatus: ConnectionStatus = .disconnected

    public init(
        webSocketService: any StockWebSocketService
    ) {
        self.webSocketService = webSocketService
    }

    public func observeConnectionStatus() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            let id = UUID()
            addStatusContinuation(continuation, id: id)

            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.removeStatusContinuation(id: id)
                }
            }
        }
    }
    
    private func addStatusContinuation(_ continuation: AsyncStream<ConnectionStatus>.Continuation, id: UUID) {
        statusContinuations[id] = continuation
        continuation.yield(connectionStatus)
    }
    
    private func removeStatusContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }
}
