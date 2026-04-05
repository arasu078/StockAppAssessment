import SwiftUI

public extension StockSortOption {
    var localizedTitleKey: LocalizedStringKey {
        switch self {
        case .price:
            return "sort_price"
        case .change:
            return "sort_change"
        }
    }
}
