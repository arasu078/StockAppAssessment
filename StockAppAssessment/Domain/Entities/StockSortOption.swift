public enum StockSortOption: String, CaseIterable, Identifiable {
    case price
    case change

    public var id: String { rawValue }
}
