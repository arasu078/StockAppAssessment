//
//  ContentView.swift
//  StockAppAssessment
//
//  Created by Ponnarasu on 05/04/2026.
//

import SwiftUI

struct ContentView: View {
    private let container: AppContainer
    @StateObject private var viewModel: SymbolsListViewModel

    init(container: AppContainer = .live()) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: container.makeSymbolsListViewModel()
        )
    }

    var body: some View {
        SymbolsListView(viewModel: viewModel, container: container)
    }
}

#Preview {
    ContentView()
}
