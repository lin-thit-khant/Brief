//
//  BriefingModel.swift
//  Brief
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//

import Observation
import Foundation

enum WeatherScreen {
    case loading
    case loaded(temperature: Double, condition: String, stories: [Story], fetchedAt: Date)
    case failed(String)
}

@Observable
final class BriefingModel {
    var screen = WeatherScreen.loading
    
    private let client: any BriefingClient
    
    init(client: any BriefingClient = LiveBriefingClient()) {
        self.client = client
    }
    
    func load() async {
        do {
            let weather = try await client.weather()
            let stories = try await client.stories()
            let briefing = Briefing(weather: weather, stories: stories, featchedAt: .now)
            let file = try client.save(briefing)
            screen = .loaded(
                temperature: weather.current.temperature,
                condition: weather.current.condition,
                stories: stories,
                fetchedAt: briefing.featchedAt
            )
        } catch {
            if let briefing = try? client.cachedBriefing() {
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
