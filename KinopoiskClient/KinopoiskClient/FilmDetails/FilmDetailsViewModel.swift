//
//  FilmDetailsViewModel.swift
//  KinopoiskClientClient
//
//  Created by Toto on 02.02.2024.
//

import Foundation
import Combine

final class FilmDetailsViewModel {
    @Published private(set) var film: Film
    
    private var filmsService: FilmsService
    private var bindings = Set<AnyCancellable>()
    
    //MARK: Initialization
    init(film: Film, filmsService: FilmsService) {
        self.film = film
        self.filmsService = filmsService
        
        loadFilmDetails()
    }
    
    private func loadFilmDetails() {
        filmsService.getDetails(filmId: film.kinopoiskId)
            .receive(on: RunLoop.main)
            //If we don't succeed to receive FilmDetails it's ok
            //just to use initial film data
            .replaceError(with: film)
            .sink { [weak self] film in
                self?.film = film
            }.store(in: &bindings)
    }
}
