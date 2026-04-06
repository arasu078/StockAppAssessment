import Foundation
import Testing
import StockAppAssessment

@MainActor
struct ViewModelTests {
    @Test
    func symbolsListViewModelSortsByPriceByDefault() async {
        let repository = MockStockRepository(
            initialStocks: [
                makeQuote(symbol: "AAA", price: 100, change: 1),
                makeQuote(symbol: "BBB", price: 300, change: 3),
                makeQuote(symbol: "CCC", price: 200, change: 2)
            ]
        )

        let viewModel = SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: repository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
            observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
        )

        await waitUntil {
            await MainActor.run {
                viewModel.stocks.map(\.symbol) == ["BBB", "CCC", "AAA"]
            }
        }

        let sortedByPriceSymbols = await MainActor.run { viewModel.stocks.map(\.symbol) }
        #expect(sortedByPriceSymbols == ["BBB", "CCC", "AAA"])
    }

    @Test
    func symbolsListViewModelSortsByAbsoluteChangeWhenRequested() async {
        let repository = MockStockRepository(
            initialStocks: [
                makeQuote(symbol: "AAA", price: 100, change: 1),
                makeQuote(symbol: "BBB", price: 300, change: -5),
                makeQuote(symbol: "CCC", price: 200, change: 2)
            ]
        )

        let viewModel = SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: repository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
            observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
        )

        await waitUntil {
            await MainActor.run {
                viewModel.stocks.count == 3
            }
        }
        viewModel.sortOption = .change
        await waitUntil {
            await MainActor.run {
                viewModel.stocks.map(\.symbol) == ["BBB", "CCC", "AAA"]
            }
        }

        let sortedByChangeSymbols = await MainActor.run { viewModel.stocks.map(\.symbol) }
        #expect(sortedByChangeSymbols == ["BBB", "CCC", "AAA"])
    }

    @Test
    func toggleConnectionStartsFeedWhenDisconnected() async {
        let repository = MockStockRepository(initialConnectionStatus: .disconnected)
        let viewModel = SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: repository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
            observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
        )

        await waitUntil {
            await MainActor.run {
                viewModel.connectionStatus == .disconnected
            }
        }
        viewModel.toggleConnection()
        await waitUntil {
            await MainActor.run {
                repository.startCallCount == 1
            }
        }

        let startCallCount = await MainActor.run { repository.startCallCount }
        #expect(startCallCount == 1)
    }

    @Test
    func toggleConnectionStopsFeedWhenConnected() async {
        let repository = MockStockRepository(initialConnectionStatus: .connected)
        let viewModel = SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: repository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
            observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
        )

        await waitUntil {
            await MainActor.run {
                viewModel.connectionStatus == .connected
            }
        }
        viewModel.toggleConnection()
        await waitUntil {
            await MainActor.run {
                repository.stopCallCount == 1
            }
        }

        let stopCallCount = await MainActor.run { repository.stopCallCount }
        #expect(stopCallCount == 1)
    }

    @Test
    func symbolDetailViewModelTracksSelectedSymbol() async {
        let repository = MockStockRepository(
            initialStocks: [
                makeQuote(symbol: "AAA", price: 100),
                makeQuote(symbol: "BBB", price: 300)
            ]
        )

        let viewModel = SymbolDetailViewModel(
            symbol: "BBB",
            observeStocksUseCase: ObserveStocksUseCase(repository: repository)
        )

        await waitUntil {
            await MainActor.run {
                viewModel.stock?.symbol == "BBB"
            }
        }
        let initialSymbol = await MainActor.run { viewModel.stock?.symbol }
        #expect(initialSymbol == "BBB")

        repository.yieldStocks([
            makeQuote(symbol: "AAA", price: 100),
            makeQuote(symbol: "BBB", price: 350, change: 50)
        ])
        await waitUntil {
            await MainActor.run {
                viewModel.stock?.currentPrice == 350 && viewModel.stock?.priceChange == 50
            }
        }

        let finalStock = await MainActor.run { viewModel.stock }
        #expect(finalStock?.currentPrice == 350)
        #expect(finalStock?.priceChange == 50)
    }

    @Test
    func symbolsListViewModelPublishesConnectionAlert() async {
        let repository = MockStockRepository()
        let viewModel = SymbolsListViewModel(
            observeStocksUseCase: ObserveStocksUseCase(repository: repository),
            observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
            observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
            startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
            stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
        )

        repository.yieldAlert(.connectionLost)

        await waitUntil {
            await MainActor.run {
                viewModel.activeAlert?.kind == .connectionLost
            }
        }

        let activeAlert = await MainActor.run { viewModel.activeAlert }
        #expect(activeAlert?.kind == .connectionLost)
    }

    @Test
    func symbolsListViewModelCanDeallocateAfterBindingToRepositoryStreams() async {
        let repository = MockStockRepository(
            initialStocks: [makeQuote(symbol: "AAA", price: 100)]
        )
        weak var weakViewModel: SymbolsListViewModel?

        do {
            var viewModel: SymbolsListViewModel? = SymbolsListViewModel(
                observeStocksUseCase: ObserveStocksUseCase(repository: repository),
                observeConnectionStatusUseCase: ObserveConnectionStatusUseCase(repository: repository),
                observeAlertsUseCase: ObserveAlertsUseCase(repository: repository),
                startPriceFeedUseCase: StartPriceFeedUseCase(repository: repository),
                stopPriceFeedUseCase: StopPriceFeedUseCase(repository: repository)
            )
            weakViewModel = viewModel

            await waitUntil {
                await MainActor.run {
                    viewModel?.stocks.count == 1
                }
            }

            viewModel = nil
        }

        await waitUntil {
            await MainActor.run {
                weakViewModel == nil
            }
        }

        #expect(weakViewModel == nil)
    }

    @Test
    func symbolDetailViewModelCanDeallocateAfterBindingToRepositoryStreams() async {
        let repository = MockStockRepository(
            initialStocks: [makeQuote(symbol: "BBB", price: 300)]
        )
        weak var weakViewModel: SymbolDetailViewModel?

        do {
            var viewModel: SymbolDetailViewModel? = SymbolDetailViewModel(
                symbol: "BBB",
                observeStocksUseCase: ObserveStocksUseCase(repository: repository)
            )
            weakViewModel = viewModel

            await waitUntil {
                await MainActor.run {
                    viewModel?.stock?.symbol == "BBB"
                }
            }

            viewModel = nil
        }

        await waitUntil {
            await MainActor.run {
                weakViewModel == nil
            }
        }

        #expect(weakViewModel == nil)
    }
}
