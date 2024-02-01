//
//  FilmCellViewModel.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation

final class FilmCellViewModel {
    @Published var title: String = ""
    @Published var description: String = ""
    //TODO: go away from UIKit in Model, replace with data & use it in interface
    //@Published var posterImage: UIImage = ""
        
    private let film: Film
    
    init(film: Film) {
        self.film = film
        
        setUpBindings()
    }
    
    private func setUpBindings() {
        title = film.nameRu ?? "Unnamed movie"
        fillDescription()
        //TODO: image
    }
    
    private func fillDescription() {
        let countries = film.countries.shortenTo3
        let genres = film.genres.shortenTo3
        
        if !countries.isEmpty && !genres.isEmpty {
            description = "\(countries), \(genres), \(film.year)"
        } else if !countries.isEmpty && genres.isEmpty{
            description = "\(countries), \(film.year)"
        } else if countries.isEmpty && !genres.isEmpty{
            description = "\(genres), \(film.year)"
        } else {
            description = "\(film.year)"
        }
    }
}

private extension Array where Element == String {
    var shortenTo3: String {
        self.count > 3 ?
        "\(self[0..<3].joined(separator: ", "))[...]" :
        "\(self.joined(separator: ", "))"
    }
}
