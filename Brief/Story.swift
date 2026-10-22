//
//  Story.swift
//  Brief
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//

import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String?
}

func fetchStories() async throws -> [Story] {
    guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
        throw URLError(.badURL)
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    let ids = try JSONDecoder().decode([Int].self, from: data)
    
    var stories: [Story] = []
    for id in ids.prefix(5) {
        guard let itemURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
            throw URLError(.badURL)
        }
        let (itemData, _) = try await URLSession.shared.data(from: itemURL)
        stories.append(try JSONDecoder().decode(Story.self, from: itemData))
    }
    return stories
}
