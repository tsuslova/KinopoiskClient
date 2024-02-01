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
        //TODO: description, image
    }

}
