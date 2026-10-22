//
//  ContentView.swift
//  Brief
//
//  Created by Lin Thit Khant on 21/10/2569 BE.
//

import SwiftUI

enum WeatherScreen {
    case loading
    case loaded(temperature: Double, condition: String)
    case failed(String)
}

struct ContentView: View {
    @State private var screen = WeatherScreen.loading
    
    var body: some View {
        VStack {
            switch screen {
            case .loading:
                ProgressView()
            case .loaded(let temperature, let condition):
                Text("\(temperature)°C")
                Text(condition)
            case .failed(let message):
                Text(message)
            }
        }
        .padding()
        .task {
            do {
                let weather = try await fetchCurrentWeather()
                screen = .loaded(
                    temperature: weather.current.temperature,
                    condition: weather.current.condition
                )
            } catch {
                screen = .failed(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
