# StockTrackerAssessment

SwiftUI iOS app that simulates live stock prices for 25 symbols through a WebSocket echo flow using `wss://ws.postman-echo.com/raw`.

## App Summary

- Displays 25 stock symbols with current price and trend
- Supports live updates through Start/Stop feed controls
- Keeps list and detail screens in sync from a single source of truth
- Supports localization through `Localizable.xcstrings`
- Uses Clean Architecture with Presentation, Domain, Data, App, Support, and Resources structure

## Current Folder Structure

```text
StockTrackerAssessment/
├── App/
│   ├── AppContainer.swift
│   └── ContentView.swift
├── Data/
│   ├── DTOs/
│   ├── Repositories/
│   ├── Services/
│   └── Support/
├── Domain/
│   ├── Entities/
│   ├── Protocols/
│   └── UseCases/
├── Presentation/
│   ├── Extensions/
│   ├── ViewModels/
│   └── Views/
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.xcstrings
├── Support/
│   ├── AppConstants.swift
│   └── LocalizationKeyReferences.swift
└── StockTrackerAssessmentApp.swift
```

## Data Flow

1. `ContentView` creates the app graph through `AppContainer`.
2. `AppContainer` creates one shared repository instance and uses it to build use cases and view models.
3. `SymbolsListViewModel` subscribes to stocks, connection status, and alerts, while `SymbolDetailViewModel` subscribes to the same shared stock stream and filters by symbol.
4. When the user taps Start, `SymbolsListViewModel` triggers `StartPriceFeedUseCase`.
5. `DefaultStockRepository` opens the WebSocket connection and starts one sender loop and one receiver loop.
6. Every second, the repository sends one batched payload for a random subset of stocks.
7. Postman Echo returns the same payload.
8. The repository decodes the echoed payload, updates in-memory stock state, and broadcasts one refreshed snapshot.
9. Because both screens consume the same shared stock stream, UI state stays synchronized.

## Technical Rules

### Do

- Use `async` and `await` for asynchronous flows
- Keep business rules inside Domain and Data layers, not inside SwiftUI views
- Use `StockRepository` and use cases as the stable boundary for feature work
- Add new localization strings to `Resources/Localizable.xcstrings`
- Add reusable constants to `Support/AppConstants.swift`
- Use Swift Testing in `StockTrackerAssessmentTests`
- Prefer deterministic mocks and async polling helpers for real-time tests

### Don't

- Do not introduce Combine-based networking or state flows for new work
- Do not hardcode URLs, feature flags, or app-wide constants inside feature files
- Do not put localization strings directly in entities or views when a catalog key should be used
- Do not use `XCTest` for new tests in this codebase
- Do not create another source of truth for stock prices outside the repository
- Do not update UI state from multiple repositories or multiple WebSocket services

## Testing Notes

- Test framework: Swift Testing
- Primary coverage targets:
  - repository behavior
  - batch update generation
  - use cases
  - view models
  - domain entities
- Keep view model tests actor-safe and deterministic

## Architecture Docs

- High-level diagram: `Docs/HighLevelArchitecture.mmd`
- Low-level diagram: `Docs/LowLevelArchitecture.mmd`
- Data flow notes: `Docs/DataFlow.md`
