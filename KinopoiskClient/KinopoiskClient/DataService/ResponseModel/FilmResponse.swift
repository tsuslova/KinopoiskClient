//
//  FilmResponse.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation

struct CountryResponse: Decodable, Equatable, Hashable {
    let country: String
}
struct GenreResponse: Decodable, Equatable, Hashable {
    let genre: String
}

struct FilmResponse: Decodable, Hashable {
    let kinopoiskId: Int
    let nameRu: String?
    let posterUrl: String
    let posterUrlPreview: String
    let ratingKinopoisk: Float?
    
    let countries: [CountryResponse]
    let genres: [GenreResponse]
    let year: Int
}
