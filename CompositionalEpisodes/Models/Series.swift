//
//  Series.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import Foundation

struct Series: Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let artworkImgixUrl: URL
    let installments: [Int]

    var mediumArtworkURL: URL {
        URL(string: artworkImgixUrl.absoluteString.appending("?w=300"))!        
    }
}
