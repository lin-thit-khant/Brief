//
//  CurrentWeather.swift
//  Brief
//
//  Created by Lin Thit Khant on 22/10/2569 BE.
//
import Foundation

struct CurrentWeather: Decodable {
    let current: Reading
    
    struct Reading: Decodable {
        let temperature: Double
        let weatherCode: Int
        var condition: String {
            switch weatherCode {
            case 0: "Clear"
            case 1, 2, 3: "Cloudy"
            case 45, 48: "Fog"
            case 51, 53, 55: "Drizzle"
            case 61, 63, 65, 80, 81, 82: "Rain"
            case 71, 73, 75: "Snow"
            case 95, 96, 99: "Thunderstorm"
            default: "Unknown"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
            case weatherCode = "weather_code"
        }
    }
}

func fetchCurrentWeather() async throws -> CurrentWeather {
    guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=13.7563&longitude=100.5018&current=temperature_2m,weather_code&timezone=Asia/Bangkok") else {
        throw URLError(.badURL)
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(CurrentWeather.self, from: data)
}
