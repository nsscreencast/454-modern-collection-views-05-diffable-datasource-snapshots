//
//  DataLoader.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import Foundation
import Combine

class DataLoader {
    var episodes: [Episode] = []
    var series: [Series] = []
    
    private(set) var dataChanged = PassthroughSubject<Void, Never>()
    
    @Published
    var isLoading = false
    
    private let api = NSScreencastAPI()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        isLoading = true
        let episodesPub = api.episodesPublisher()
            .catch { error -> AnyPublisher<[Episode], Never> in
                print("Error loading episodes: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let seriesPub = api.seriesPublisher()
            .catch { error -> AnyPublisher<[Series], Never> in
                print("Error loading series: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        Publishers.CombineLatest(episodesPub, seriesPub)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                self.isLoading = false
                self.episodes = $0.0
                self.series = $0.1
                self.dataChanged.send()
            })
            .store(in: &cancellables)
    }
}
