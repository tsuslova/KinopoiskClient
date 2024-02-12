//
//  Film.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import Foundation

struct Film: Hashable {
    let kinopoiskId: Int
    let nameRu: String?
    let posterUrl: String
    let posterUrlPreview: String
    let coverUrl: String?
    let ratingKinopoisk: Float?
    
    let logoUrl: String?
    
    let countries: [String]
    let genres: [String]
    let year: Int?
    
    let nameOriginal: String?
    
    let ratingVoteCount: Int?
    let filmLength: Int?
    let ratingAgeLimits: AgeLimits?
    
    let shortDescription: String?
    let description: String?
}

//from film list (search, basic)
extension Film {
    init(filmResponse: FilmResponse) {
        kinopoiskId = filmResponse.kinopoiskId
        nameRu = filmResponse.nameRu
        
        posterUrl = filmResponse.posterUrl
        posterUrlPreview = filmResponse.posterUrlPreview
        coverUrl = nil
        ratingKinopoisk = filmResponse.ratingKinopoisk
        
        countries = filmResponse.countries?.map{ $0.country } ?? []
        genres = filmResponse.genres?.map{ $0.genre } ?? []
        year = filmResponse.year
        
        //Only available in Details Response
        logoUrl = nil
        
        nameOriginal = nil
        ratingVoteCount = nil
        filmLength = nil
        ratingAgeLimits = nil
        
        shortDescription = nil
        description = nil
    }
}

extension Film {
    init(filmDetailsResponse: FilmDetailsResponse) {
        kinopoiskId = filmDetailsResponse.kinopoiskId
        nameRu = filmDetailsResponse.nameRu
        posterUrl = filmDetailsResponse.posterUrl
        coverUrl = filmDetailsResponse.coverUrl
        posterUrlPreview = filmDetailsResponse.posterUrlPreview
        ratingKinopoisk = filmDetailsResponse.ratingKinopoisk
        
        countries = filmDetailsResponse.countries?.map{ $0.country } ?? []
        genres = filmDetailsResponse.genres?.map{ $0.genre } ?? []
        year = filmDetailsResponse.year
        
        logoUrl = filmDetailsResponse.logoUrl
        nameOriginal = filmDetailsResponse.nameOriginal
        ratingVoteCount = filmDetailsResponse.ratingVoteCount
        filmLength = filmDetailsResponse.filmLength
        if let limit = filmDetailsResponse.ratingAgeLimits {
            ratingAgeLimits = AgeLimits(rawValue: limit)
        } else {
            ratingAgeLimits = nil
        }
        shortDescription = filmDetailsResponse.shortDescription
        description = filmDetailsResponse.description
    }
}

enum AgeLimits: String {
    case age16
    case age18
    
    var humanReadable: String {
        switch self {
        case .age16: "16+"
        case .age18: "18+"
        }
        
    }
}
