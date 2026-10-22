//
//  BriefingCache.swift
//  Brief
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//

import Foundation

struct Briefing: Codable {
    let weather: CurrentWeather
    let stories: [Story]
    let featchedAt: Date
}

struct BriefingCache {
    func save(_ briefing: Briefing) throws -> URL {
        guard let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw URLError(.cannotCreateFile)
        }
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        let file = directory.appendingPathComponent("briefing.json")
        let data = try JSONEncoder().encode(briefing)
        try data.write(to: file, options: .atomic)
        return file
    }
    
    func load() throws -> Briefing? {
        guard let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw URLError(.cannotCreateFile)
        }
        let file = directory.appendingPathComponent("briefing.json")
        guard FileManager.default.fileExists(atPath: file.path) else {
            return nil
        }
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(Briefing.self, from: data)
    }
}
