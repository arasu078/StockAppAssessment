import Foundation

@MainActor
public final class DefaultStockRepository: StockRepository {
    private let webSocketService: any StockWebSocketService
    private let priceGenerator: any StockPriceGenerating
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let minimumBatchSize = 10
    private let updateInterval: Duration
    
    private var quotesBySymbol: [String: StockQuote]
    private var stockContinuations: [UUID: AsyncStream<[StockQuote]>.Continuation] = [:]
    private var statusContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]
    private var alertContinuations: [UUID: AsyncStream<StockFeedAlert>.Continuation] = [:]
    private var senderTask: Task<Void, Never>?
    private var receiverTask: Task<Void, Never>?
    private var connectionStatus: ConnectionStatus = .disconnected
    
    public init(
        webSocketService: any StockWebSocketService,
        priceGenerator: any StockPriceGenerating,
        seedQuotes: [StockQuote],
        updateInterval: Duration = .seconds(1)
    ) {
        self.webSocketService = webSocketService
        self.priceGenerator = priceGenerator
        self.updateInterval = updateInterval
        self.quotesBySymbol = Dictionary(uniqueKeysWithValues: seedQuotes.map { ($0.symbol, $0) })
    }
    
    public func observeStocks() -> AsyncStream<[StockQuote]> {
        AsyncStream { continuation in
            let id = UUID()
            addStockContinuation(continuation, id: id)
            
            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.removeStockContinuation(id: id)
                }
            }
        }
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

    public func observeAlerts() -> AsyncStream<StockFeedAlert> {
        AsyncStream { continuation in
            let id = UUID()
            addAlertContinuation(continuation, id: id)

            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.removeAlertContinuation(id: id)
                }
            }
        }
    }

    public func startPriceFeed() async {
        guard senderTask == nil, receiverTask == nil else { return }
        
        do {
            try await webSocketService.connect()
            updateConnectionStatus(.connected)
            
            let messages = webSocketService.messages()
            receiverTask = Task { [weak self, messages] in
                await self?.consume(messages: messages)
            }
            
            senderTask = Task { [weak self] in
                await self?.produceUpdates()
            }
        } catch {
            updateConnectionStatus(.disconnected)
            broadcastAlert(.connectionLost)
        }
    }
    
    public func stopPriceFeed() async {
        let hadActiveFeed = senderTask != nil || receiverTask != nil || connectionStatus == .connected
        guard hadActiveFeed else { return }
        
        senderTask?.cancel()
        receiverTask?.cancel()
        senderTask = nil
        receiverTask = nil
        await webSocketService.disconnect()
        updateConnectionStatus(.disconnected)
    }
}

extension DefaultStockRepository {

    private func addStatusContinuation(_ continuation: AsyncStream<ConnectionStatus>.Continuation, id: UUID) {
        statusContinuations[id] = continuation
        continuation.yield(connectionStatus)
    }
    
    private func removeStatusContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }
    
    private func addStockContinuation(_ continuation: AsyncStream<[StockQuote]>.Continuation, id: UUID) {
        stockContinuations[id] = continuation
        continuation.yield(snapshot())
    }

    private func removeStockContinuation(id: UUID) {
        stockContinuations.removeValue(forKey: id)
    }

    private func addAlertContinuation(_ continuation: AsyncStream<StockFeedAlert>.Continuation, id: UUID) {
        alertContinuations[id] = continuation
    }

    private func removeAlertContinuation(id: UUID) {
        alertContinuations.removeValue(forKey: id)
    }

    private func produceUpdates() async {
        while !Task.isCancelled {
            do {
                let quotes = snapshot()
                guard !quotes.isEmpty else { break }

                let updates = priceGenerator.makeUpdates(for: makeBatch(from: quotes))
                let payload = try encoder.encode(updates)
                let message = String(decoding: payload, as: UTF8.self)

                try await webSocketService.send(text: message)
                try await Task.sleep(for: updateInterval)
            } catch {
                if Task.isCancelled || error is CancellationError {
                    return
                }

                broadcastAlert(.connectionLost)
                await stopPriceFeed()
                return
            }
        }
    }

    private func consume(messages: AsyncThrowingStream<String, Error>) async {
        do {
            for try await message in messages {
                try apply(message: message)
            }
        } catch {
            if Task.isCancelled || error is CancellationError {
                return
            }

            broadcastAlert(.connectionLost)
            await stopPriceFeed()
        }
    }
    
    private func apply(message: String) throws {
        let messageDTO = try decoder.decode(StockUpdateMessageDTO.self, from: Data(message.utf8))

        for update in messageDTO.updates {
            guard var quote = quotesBySymbol[update.symbol] else { continue }

            let previousPrice = quote.currentPrice
            quote.currentPrice = update.price
            quote.priceChange = update.price - previousPrice
            quotesBySymbol[quote.symbol] = quote
        }

        broadcastStocks()
    }
    
    private func makeBatch(from quotes: [StockQuote]) -> [StockQuote] {
        let lowerBound = min(minimumBatchSize, quotes.count)
        let batchSize = Int.random(in: lowerBound ... quotes.count)

        return Array(quotes.shuffled().prefix(batchSize))
    }
    
    private func updateConnectionStatus(_ status: ConnectionStatus) {
        connectionStatus = status
        statusContinuations.values.forEach { $0.yield(status) }
    }

    private func broadcastStocks() {
        let current = snapshot()
        stockContinuations.values.forEach { $0.yield(current) }
    }

    private func broadcastAlert(_ alert: StockFeedAlert) {
        alertContinuations.values.forEach { $0.yield(alert) }
    }

    private func snapshot() -> [StockQuote] {
        quotesBySymbol.values.sorted { $0.symbol < $1.symbol }
    }
}
