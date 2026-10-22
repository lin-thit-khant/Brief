//
//  ContentView.swift
//  Brief
//
//  Created by Lin Thit Khant on 21/10/2569 BE.
//

import SwiftUI



struct ContentView: View {
    @State private var model = BriefingModel()
    
    var body: some View {
        List {
            switch model.screen {
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
            await model.load()
        }
        .refreshable {
            await model.load()
        }
    }

}

#Preview {
    ContentView()
}
