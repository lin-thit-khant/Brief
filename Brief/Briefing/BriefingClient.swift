//
//  BriefingClient.swift
//  Brief
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//

import Foundation

protocol BriefingClient {
    func weather() async throws -> CurrentWeather
    func stories() async throws -> [Story]
    func save(_ briefing: Briefing) throws -> URL
    func cachedBriefing() throws -> Briefing?
}

struct LiveBriefingClient: BriefingClient {
    func weather() async throws -> CurrentWeather {
        try await fetchCurrentWeather()
    }
    
    func stories() async throws -> [Story] {
        try await fetchStories()
    }
    
    func save(_ briefing: Briefing) throws -> URL {
        try BriefingCache().save(briefing)
    }
    
    func cachedBriefing() throws -> Briefing? {
        try BriefingCache().load()
    }
}
