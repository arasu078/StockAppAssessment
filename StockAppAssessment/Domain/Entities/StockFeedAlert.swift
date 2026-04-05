import Foundation

public struct StockFeedAlert: Identifiable, Equatable, Sendable {
    public enum Kind: Sendable {
        case connectionLost
    }

    public let id = UUID()
    public let kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    public var title: String.LocalizationValue {
        switch kind {
        case .connectionLost:
            return "alert_connection_lost_title"
        }
    }

    public var message: String.LocalizationValue {
        switch kind {
        case .connectionLost:
            return "alert_connection_lost_message"
        }
    }

    public var buttonTitle: String.LocalizationValue {
        switch kind {
        case .connectionLost:
            return "alert_connection_lost_button"
        }
    }

    public static var connectionLost: StockFeedAlert {
        StockFeedAlert(kind: .connectionLost)
    }
}
