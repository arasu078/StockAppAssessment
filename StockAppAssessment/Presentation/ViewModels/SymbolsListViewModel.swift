import Foundation
import Combine
import SwiftUI

@MainActor
public final class SymbolsListViewModel: ObservableObject {
    @Published public private(set) var stocks: [StockQuote] = []
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published public var activeAlert: StockFeedAlert?
    @Published public var sortOption: StockSortOption = .price {
        didSet {
            sortStocks()
        }
    }
    
    private let observeStocksUseCase: ObserveStocksUseCase
    private let observeConnectionStatusUseCase: ObserveConnectionStatusUseCase
    private let observeAlertsUseCase: ObserveAlertsUseCase
    private let startPriceFeedUseCase: StartPriceFeedUseCase
    private let stopPriceFeedUseCase: StopPriceFeedUseCase

    private var stockObservationTask: Task<Void, Never>?
    private var statusObservationTask: Task<Void, Never>?
    private var alertObservationTask: Task<Void, Never>?

    public init(
        observeStocksUseCase: ObserveStocksUseCase,
        observeConnectionStatusUseCase: ObserveConnectionStatusUseCase,
        observeAlertsUseCase: ObserveAlertsUseCase,
        startPriceFeedUseCase: StartPriceFeedUseCase,
        stopPriceFeedUseCase: StopPriceFeedUseCase
    ) {
        self.observeStocksUseCase = observeStocksUseCase
        self.observeConnectionStatusUseCase = observeConnectionStatusUseCase
        self.observeAlertsUseCase = observeAlertsUseCase
        self.startPriceFeedUseCase = startPriceFeedUseCase
        self.stopPriceFeedUseCase = stopPriceFeedUseCase
        bind()
    }

    deinit {
        stockObservationTask?.cancel()
        statusObservationTask?.cancel()
        alertObservationTask?.cancel()
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
        let alertsStream = observeAlertsUseCase.execute()

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

        alertObservationTask = Task { [weak self] in
            for await alert in alertsStream {
                guard let self else { return }
                self.activeAlert = alert
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
