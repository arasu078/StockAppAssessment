import Foundation
import Testing
import StockAppAssessment

@MainActor
final class MockStockRepository: StockRepository, @unchecked Sendable {
    private var currentStocks: [StockQuote]
    private var currentConnectionStatus: ConnectionStatus
    private var stockContinuations: [UUID: AsyncStream<[StockQuote]>.Continuation] = [:]
    private var connectionContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]
    private var alertContinuations: [UUID: AsyncStream<StockFeedAlert>.Continuation] = [:]

    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    init(
        initialStocks: [StockQuote] = [],
        initialConnectionStatus: ConnectionStatus = .disconnected
    ) {
        self.currentStocks = initialStocks
        self.currentConnectionStatus = initialConnectionStatus
    }

    func observeStocks() -> AsyncStream<[StockQuote]> {
        AsyncStream { continuation in
            let id = UUID()
            stockContinuations[id] = continuation
            continuation.yield(currentStocks)

            continuation.onTermination = { _ in
                Task { @MainActor in
                    self.stockContinuations.removeValue(forKey: id)
                }
            }
        }
    }

    func observeConnectionStatus() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            let id = UUID()
            connectionContinuations[id] = continuation
            continuation.yield(currentConnectionStatus)

            continuation.onTermination = { _ in
                Task { @MainActor in
                    self.connectionContinuations.removeValue(forKey: id)
                }
            }
        }
    }

    func observeAlerts() -> AsyncStream<StockFeedAlert> {
        AsyncStream { continuation in
            let id = UUID()
            alertContinuations[id] = continuation

            continuation.onTermination = { _ in
                Task { @MainActor in
                    self.alertContinuations.removeValue(forKey: id)
                }
            }
        }
    }

    func startPriceFeed() async {
        startCallCount += 1
        yieldConnectionStatus(.connected)
    }

    func stopPriceFeed() async {
        stopCallCount += 1
        yieldConnectionStatus(.disconnected)
    }

    func yieldStocks(_ stocks: [StockQuote]) {
        currentStocks = stocks
        stockContinuations.values.forEach { $0.yield(stocks) }
    }

    func yieldConnectionStatus(_ status: ConnectionStatus) {
        currentConnectionStatus = status
        connectionContinuations.values.forEach { $0.yield(status) }
    }

    func yieldAlert(_ alert: StockFeedAlert) {
        alertContinuations.values.forEach { $0.yield(alert) }
    }
}

@MainActor
final class MockStockWebSocketService: StockWebSocketService, @unchecked Sendable {
    private let autoEcho: Bool
    private let messagesStream: AsyncThrowingStream<String, Error>
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    private(set) var connectCallCount = 0
    private(set) var disconnectCallCount = 0
    private(set) var sentMessages: [String] = []

    init(autoEcho: Bool = true) {
        self.autoEcho = autoEcho

        var continuation: AsyncThrowingStream<String, Error>.Continuation?
        self.messagesStream = AsyncThrowingStream { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation
    }

    func connect() async throws {
        connectCallCount += 1
    }

    func disconnect() async {
        disconnectCallCount += 1
        continuation?.finish()
    }

    func send(text: String) async throws {
        sentMessages.append(text)
        if autoEcho {
            continuation?.yield(text)
        }
    }

    func messages() -> AsyncThrowingStream<String, Error> {
        messagesStream
    }

    func push(_ text: String) {
        continuation?.yield(text)
    }
}

struct FixedStockPriceGenerator: StockPriceGenerating, Sendable {
    let delta: Double

    func makeUpdates(for quotes: [StockQuote]) -> StockUpdateMessageDTO {
        StockUpdateMessageDTO(
            updates: quotes.map { quote in
                StockPriceUpdateDTO(
                    symbol: quote.symbol,
                    price: quote.currentPrice + delta
                )
            }
        )
    }
}

func makeQuote(
    symbol: String,
    price: Double,
    change: Double = 0,
    descriptionKey: StockDescriptionKey = .nvda
) -> StockQuote {
    StockQuote(
        symbol: symbol,
        companyName: "\(symbol) Inc",
        descriptionKey: descriptionKey,
        currentPrice: price,
        priceChange: change
    )
}

func makeQuotes(count: Int) -> [StockQuote] {
    (0 ..< count).map { index in
        makeQuote(
            symbol: "SYM\(index)",
            price: Double(100 + index),
            descriptionKey: .nvda
        )
    }
}

func waitUntil(
    timeout: Duration = .seconds(1),
    pollInterval: Duration = .milliseconds(10),
    condition: @escaping @Sendable () async -> Bool
) async {
    let deadline = ContinuousClock.now + timeout

    while ContinuousClock.now < deadline {
        if await condition() {
            return
        }

        try? await Task.sleep(for: pollInterval)
    }

    Issue.record("Timed out waiting for condition")
}
