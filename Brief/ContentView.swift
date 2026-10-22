//
//  ContentView.swift
//  Brief
//
//  Created by Lin Thit Khant on 21/10/2569 BE.
//

import SwiftUI

enum WeatherScreen {
    case loading
    case loaded(temperature: Double, condition: String, stories: [Story], fetchedAt: Date)
    case failed(String)
}

struct ContentView: View {
    @State private var screen = WeatherScreen.loading
    
    var body: some View {
        List {
            switch screen {
            case .loading:
                ProgressView()
            case .loaded(let temperature, let condition, let stories, let fetchedAt):
                Text("\(temperature)°C")
                Text(condition)
                ForEach(stories) { story in
                    Text(story.title)
                }
                Text(fetchedAt.formatted(date: .abbreviated, time: .shortened))
            case .failed(let message):
                Text(message)
            }
        }
        .task {
            await loadBriefing()
        }
        .refreshable {
            await loadBriefing()
        }
    }
    
    private func loadBriefing() async {
        do {
            let weather = try await fetchCurrentWeather()
            let stories = try await fetchStories()
            let briefing = Briefing(weather: weather, stories: stories, featchedAt: .now)
            let file = try BriefingCache().save(briefing)
            print(file.path)
            screen = .loaded(
                temperature: weather.current.temperature,
                condition: weather.current.condition,
                stories: stories,
                fetchedAt: briefing.featchedAt
            )
        } catch {
            if let briefing = try? BriefingCache().load() {
                screen = .loaded(
                    temperature: briefing.weather.current.temperature,
                    condition: briefing.weather.current.condition,
                    stories: briefing.stories,
                    fetchedAt: briefing.featchedAt
                )
            } else {
                screen = .failed(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
