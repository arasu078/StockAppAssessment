import Foundation
import Combine
import SwiftUI

@MainActor
public final class SymbolsListViewModel: ObservableObject {
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected

    private let observeConnectionStatusUseCase: ObserveConnectionStatusUseCase
    private var statusObservationTask: Task<Void, Never>?

    public init(
        observeConnectionStatusUseCase: ObserveConnectionStatusUseCase,
    ) {
        self.observeConnectionStatusUseCase = observeConnectionStatusUseCase
        bind()
    }

    deinit {
        statusObservationTask?.cancel()
    }

    public var isConnected: Bool {
        connectionStatus == .connected
    }

    public func toggleConnection() {
        Task {
            if isConnected {
                print("connected..")
            } else {
                print("disconnected..")
            }
        }
    }

    private func bind() {
        let statusStream = observeConnectionStatusUseCase.execute()

        statusObservationTask = Task { [weak self] in
            for await status in statusStream {
                guard let self else { return }
                self.connectionStatus = status
            }
        }
    }
}
