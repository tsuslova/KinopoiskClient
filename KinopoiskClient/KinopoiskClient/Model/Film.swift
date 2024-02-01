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
    
    let countries: [String]
    let genres: [String]
    let year: Int
    
    init(kinopoiskId: Int, nameRu: String?, posterUrl: String, posterUrlPreview: String, ratingKinopoisk: Float? = nil) {
        self.kinopoiskId = kinopoiskId
        self.nameRu = nameRu
        self.posterUrl = posterUrl
        self.posterUrlPreview = posterUrlPreview
        self.ratingKinopoisk = ratingKinopoisk
        
        self.countries = []
        self.genres = []
        self.year = 1900
    }
}

extension Film {
    init(filmResponse: FilmResponse) {
        kinopoiskId = filmResponse.kinopoiskId
        nameRu = filmResponse.nameRu
        posterUrl = filmResponse.posterUrl
        posterUrlPreview = filmResponse.posterUrlPreview
        ratingKinopoisk = filmResponse.ratingKinopoisk
        
        countries = filmResponse.countries.map{ $0.country }
        genres = filmResponse.genres.map{ $0.genre }
        year = filmResponse.year
    }
}
