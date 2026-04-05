//
//  ContentView.swift
//  StockAppAssessment
//
//  Created by Ponnarasu on 05/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("stocks_title")
                .font(.title2.weight(.semibold))

            Text("connection_connected")
                .foregroundStyle(.secondary)

            Text(String(localized: "stock_description_aapl"))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
