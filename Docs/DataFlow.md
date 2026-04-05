# Data Flow

1. `StockTrackerAssessmentApp` renders `ContentView`.
2. `ContentView` builds dependencies through `AppContainer`.
3. `AppContainer` owns one shared `StockRepository` and creates view models on demand.
4. `SymbolsListViewModel` and `SymbolDetailViewModel` receive use cases created by `AppContainer`.
5. Both view models subscribe to their required repository-backed streams during initialization:
   - `SymbolsListViewModel` subscribes to stocks, connection status, and alerts
   - `SymbolDetailViewModel` subscribes to the shared stocks stream and filters by symbol
6. `SymbolsListViewModel` starts the feed through `StartPriceFeedUseCase`.
7. `DefaultStockRepository` connects through `PostmanEchoWebSocketService`.
8. Every second, the repository:
   - takes the latest stock snapshot
   - picks a random subset from 10 up to the current list size
   - generates a batched `StockUpdateMessageDTO`
   - sends the payload to Postman Echo
9. The echoed payload is received by the WebSocket service and consumed by the repository.
10. The repository decodes the payload, updates the in-memory stocks, recalculates `priceChange`, and emits one new snapshot to every stock observer.
11. If the WebSocket fails, the repository emits a fresh `StockFeedAlert` stream item for the UI and updates connection status to `.disconnected`.
12. Because both screens observe the same repository-backed stock stream, list and detail stay synchronized from one source of truth.
13. Presentation-layer extensions resolve localized text and status styling for the UI, while `Support/AppConstants.swift` provides shared constants and `Support/LocalizationKeyReferences.swift` helps keep string-catalog entries referenced.
