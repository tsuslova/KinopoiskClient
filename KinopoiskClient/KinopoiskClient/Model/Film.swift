//
//  Film.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import Foundation

struct Film: Decodable, Hashable {
    let kinopoiskId: Int
    let nameRu: String?
    let posterUrl: String
    let posterUrlPreview: String
    let ratingKinopoisk: Float?

    var name: String {
        nameRu ?? "Unknown movie"
    }
    
    //TODO: add mapping from FilmResponse
    init(kinopoiskId: Int, nameRu: String?, posterUrl: String, posterUrlPreview: String, ratingKinopoisk: Float? = nil) {
        self.kinopoiskId = kinopoiskId
        self.nameRu = nameRu
        self.posterUrl = posterUrl
        self.posterUrlPreview = posterUrlPreview
        self.ratingKinopoisk = ratingKinopoisk
    }
}
