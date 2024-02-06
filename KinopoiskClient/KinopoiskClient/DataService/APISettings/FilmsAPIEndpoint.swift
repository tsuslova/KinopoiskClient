//
//  FilmsAPIEndpoint.swift
//  Kinopoisk
//
//  Created by Toto on 29.01.2024.
//

import Foundation

enum APIType: String{
    //At the moment only films-related API subset is planned to be used.
    case films
}

//At the moment only films API is planned to be used.
//In case othe Kinopoisk API is involved more generic approach might be needed
enum FilmsAPIEndpoint{
    
    case root
    case search
    case details(filmId: Int)
    
    static var api: APIType = .films
    
    static func baseUrl() -> URL {
        URL(string: KinopoiskDefaults.apiURL)!
    }

    var url: URL {
        switch self {
        case .root, .search:
            return FilmsAPIEndpoint.filmsAPI().appendingPathExtension(path)
        default:
            return FilmsAPIEndpoint.filmsAPI().appending(path: path, directoryHint: .notDirectory)
        }
    }
 
    static func filmsAPI() -> URL {
        return baseUrl().appending(path: api.rawValue)
    }
    
    var path: String {
        switch self {
        case .root:
            return ""
        case .search:
            //The Kinopoisk API has changed between 2.1 and 2.2. now search is
            //just a part of films(root) request. For the moment leave a separate
            //request (in case they change their mind again), but may be it's not
            //necessary anymore...
            return ""
        case .details(let filmId):
            return "/\(filmId)"
        }
    }
}
