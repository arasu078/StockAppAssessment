import Foundation

@MainActor
public protocol StockWebSocketService: Sendable {
    func connect() async throws
    func disconnect() async
    func send(text: String) async throws
    func messages() -> AsyncThrowingStream<String, Error>
}

public enum WebSocketServiceError: Error {
    case notConnected
}

@MainActor
public final class PostmanEchoWebSocketService: StockWebSocketService {
    private let url: URL
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var continuations: [UUID: AsyncThrowingStream<String, Error>.Continuation] = [:]

    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }

    public func connect() async throws {
        guard webSocketTask == nil else { return }

        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        receiveTask = Task { [weak self] in
            await self?.receiveLoop()
        }
    }

    public func disconnect() async {
        receiveTask?.cancel()
        receiveTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        finishContinuations()
    }

    public func send(text: String) async throws {
        guard let webSocketTask else {
            throw WebSocketServiceError.notConnected
        }

        try await webSocketTask.send(.string(text))
    }

    public func messages() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let id = UUID()
            addContinuation(continuation, id: id)

            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    self?.removeContinuation(id: id)
                }
            }
        }
    }

    private func addContinuation(_ continuation: AsyncThrowingStream<String, Error>.Continuation, id: UUID) {
        continuations[id] = continuation
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func receiveLoop() async {
        while !Task.isCancelled {
            guard let webSocketTask else { return }

            do {
                let message = try await webSocketTask.receive()

                switch message {
                case .string(let text):
                    yield(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        yield(text)
                    }
                @unknown default:
                    break
                }
            } catch {
                finishContinuations(error: error)
                self.webSocketTask = nil
                return
            }
        }
    }

    private func yield(_ message: String) {
        continuations.values.forEach { $0.yield(message) }
    }

    private func finishContinuations(error: Error? = nil) {
        continuations.values.forEach { continuation in
            if let error {
                continuation.finish(throwing: error)
            } else {
                continuation.finish()
            }
        }
        continuations.removeAll()
    }
}
