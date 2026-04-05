import Foundation
import Combine
import SwiftUI

@MainActor
public final class SymbolDetailViewModel: ObservableObject {
    @Published public private(set) var stock: StockQuote?

    private let symbol: String
    private let observeStocksUseCase: ObserveStocksUseCase
    private var observationTask: Task<Void, Never>?

    public init(symbol: String, observeStocksUseCase: ObserveStocksUseCase) {
        self.symbol = symbol
        self.observeStocksUseCase = observeStocksUseCase
        bind()
    }

    deinit {
        observationTask?.cancel()
    }

    private func bind() {
        let stocksStream = observeStocksUseCase.execute()

        observationTask = Task { [weak self] in
            for await quotes in stocksStream {
                guard let self else { return }
                self.stock = quotes.first(where: { $0.symbol == self.symbol })
            }
        }
    }
}
