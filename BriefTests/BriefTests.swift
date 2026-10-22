//
//  BriefTests.swift
//  BriefTests
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//

import Testing
import Foundation
@testable import Brief

struct BriefTests {
    
    @Test func newModelIsLoading() {
        let model = BriefingModel()
        if case .loading = model.screen {
            #expect(true)
        } else {
            Issue.record("A new model starts in loading")
        }
    }
    
    @Test func decodesWeatherPayload() throws {
        let json = """
            {"current":{"temperature_2m":29.0,"weather_code":51}}
            """
        let weather = try JSONDecoder().decode(CurrentWeather.self, from: Data(json.utf8))
        #expect(weather.current.temperature == 29)
        #expect(weather.current.weatherCode == 51)
        #expect(weather.current.condition == "Drizzle")
    }
    
    @Test func decodesStoryPayload() throws {
        let json = """
        {"id":8863,"title":"Dropbox","url":"https://example.com"}
        """
        let story = try JSONDecoder().decode(Story.self, from: Data(json.utf8))
        #expect(story.id == 8863)
        #expect(story.title == "Dropbox")
        #expect(story.url == "https://example.com")
    }
    
    @Test func malformedWeatherPayloadThrows() {
        let json = "{}"
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(CurrentWeather.self, from: Data(json.utf8))
        }
    }
    
    struct ScriptedClient: BriefingClient {
        var weatherResult: Result<CurrentWeather, Error>
        var storiesResult: Result<[Story], Error>
        var cached: Briefing?
        
        func weather() async throws -> CurrentWeather {
            try weatherResult.get()
        }
        
        func stories() async throws -> [Story] {
            try storiesResult.get()
        }
        
        func save(_ briefing: Briefing) throws -> URL {
            URL(fileURLWithPath: "/tmp/briefing.json")
        }
        
        func cachedBriefing() throws -> Briefing? {
            cached
        }
    }
    
    @Test func loadShowsFetchedBriefing() async {
        let weather = CurrentWeather(current: .init(temperature: 29, weatherCode: 51))
        let stories = [Story(id: 8863, title: "Dropbox", url: "https://example.com")]
        let model = BriefingModel(client: ScriptedClient(
            weatherResult: .success(weather),
            storiesResult: .success(stories),
            cached: nil
        ))

        await model.load()

        guard case .loaded(let temperature, let condition, let loadedStories, _) = model.screen else {
            Issue.record("Expected loaded")
            return
        }
        #expect(temperature == 29)
        #expect(condition == "Drizzle")
        #expect(loadedStories.map(\.title) == ["Dropbox"])
    }

    @Test func failedLoadShowsSavedBriefing() async {
        let saved = Briefing(
            weather: CurrentWeather(current: .init(temperature: 29, weatherCode: 51)),
            stories: [Story(id: 8863, title: "Dropbox", url: "https://example.com")],
            featchedAt: Date(timeIntervalSince1970: 0)
        )
        let model = BriefingModel(client: ScriptedClient(
            weatherResult: .failure(URLError(.notConnectedToInternet)),
            storiesResult: .failure(URLError(.notConnectedToInternet)),
            cached: saved
        ))

        await model.load()

        guard case .loaded(let temperature, _, _, let fetchedAt) = model.screen else {
            Issue.record("Expected the saved briefing")
            return
        }
        #expect(temperature == 29)
        #expect(fetchedAt == saved.featchedAt)
    }

    @Test func failedLoadWithoutCacheShowsError() async {
        let error = URLError(.notConnectedToInternet)
        let model = BriefingModel(client: ScriptedClient(
            weatherResult: .failure(error),
            storiesResult: .failure(error),
            cached: nil
        ))

        await model.load()

        guard case .failed(let message) = model.screen else {
            Issue.record("Expected failed")
            return
        }
        #expect(message == error.localizedDescription)
    }
}
