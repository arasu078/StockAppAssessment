import SwiftUI

public extension ConnectionStatus {
    var localizedTitleKey: LocalizedStringKey {
        switch self {
        case .connected:
            return "connection_connected"
        case .disconnected:
            return "connection_disconnected"
        }
    }

    var tint: Color {
        switch self {
        case .connected:
            return .green
        case .disconnected:
            return .red
        }
    }
}
