import Foundation

public extension StockQuote {
    var localizedDescription: LocalizedStringResource {
        descriptionKey.localizedStringResource
    }
}

public extension StockDescriptionKey {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .aapl:
            return "stock_description_aapl"
        case .adbe:
            return "stock_description_adbe"
        case .amd:
            return "stock_description_amd"
        case .amzn:
            return "stock_description_amzn"
        case .arm:
            return "stock_description_arm"
        case .asml:
            return "stock_description_asml"
        case .avgo:
            return "stock_description_avgo"
        case .crm:
            return "stock_description_crm"
        case .goog:
            return "stock_description_goog"
        case .ibm:
            return "stock_description_ibm"
        case .intc:
            return "stock_description_intc"
        case .meta:
            return "stock_description_meta"
        case .msft:
            return "stock_description_msft"
        case .mu:
            return "stock_description_mu"
        case .nflx:
            return "stock_description_nflx"
        case .nvda:
            return "stock_description_nvda"
        case .orcl:
            return "stock_description_orcl"
        case .pltr:
            return "stock_description_pltr"
        case .pypl:
            return "stock_description_pypl"
        case .qcom:
            return "stock_description_qcom"
        case .sap:
            return "stock_description_sap"
        case .shop:
            return "stock_description_shop"
        case .snow:
            return "stock_description_snow"
        case .tsla:
            return "stock_description_tsla"
        case .uber:
            return "stock_description_uber"
        }
    }
}
