import Foundation
import Combine
import SwiftUI

@MainActor
public final class SymbolsListViewModel: ObservableObject {
    @Published public private(set) var stocks: [StockQuote] = []
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published public var sortOption: StockSortOption = .price {
        didSet {
            sortStocks()
        }
    }
    
    private let observeStocksUseCase: ObserveStocksUseCase
    private let observeConnectionStatusUseCase: ObserveConnectionStatusUseCase
    private let startPriceFeedUseCase: StartPriceFeedUseCase
    private let stopPriceFeedUseCase: StopPriceFeedUseCase

    private var stockObservationTask: Task<Void, Never>?
    private var statusObservationTask: Task<Void, Never>?

    public init(
        observeStocksUseCase: ObserveStocksUseCase,
        observeConnectionStatusUseCase: ObserveConnectionStatusUseCase,
        startPriceFeedUseCase: StartPriceFeedUseCase,
        stopPriceFeedUseCase: StopPriceFeedUseCase
    ) {
        self.observeStocksUseCase = observeStocksUseCase
        self.observeConnectionStatusUseCase = observeConnectionStatusUseCase
        self.startPriceFeedUseCase = startPriceFeedUseCase
        self.stopPriceFeedUseCase = stopPriceFeedUseCase
        bind()
    }

    deinit {
        stockObservationTask?.cancel()
        statusObservationTask?.cancel()
    }

    public var isConnected: Bool {
        connectionStatus == .connected
    }

    public func toggleConnection() {
        Task {
            if isConnected {
                await stopPriceFeedUseCase.execute()
            } else {
                await startPriceFeedUseCase.execute()
            }
        }
    }

    private func bind() {
        let stocksStream = observeStocksUseCase.execute()
        let statusStream = observeConnectionStatusUseCase.execute()

        stockObservationTask = Task { [weak self] in
            for await quotes in stocksStream {
                guard let self else { return }
                self.stocks = quotes
                self.sortStocks()
            }
        }

        statusObservationTask = Task { [weak self] in
            for await status in statusStream {
                guard let self else { return }
                self.connectionStatus = status
            }
        }
    }
    
    private func sortStocks() {
        switch sortOption {
        case .price:
            stocks.sort { $0.currentPrice > $1.currentPrice }
        case .change:
            stocks.sort { abs($0.priceChange) > abs($1.priceChange) }
        }
    }
}
