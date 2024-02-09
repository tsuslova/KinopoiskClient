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
    @Published private(set) var coverImageData: Data?
    
    private var filmsService: FilmsService
    private var bindings = Set<AnyCancellable>()
    
    private var coverImageLoader = CacheImageLoader()
    
    //MARK: Initialization
    init(film: Film, filmsService: FilmsService) {
        self.film = film
        self.filmsService = filmsService
    }
    
    func loadFilmDetails() {
        setUpBindings()
        loadFilmDetailsData()
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        coverImageLoader.$imageData.assign(to: &$coverImageData)
    }
    
    private func loadFilmDetailsData() {
        filmsService.getDetails(filmId: film.kinopoiskId)
            .receive(on: RunLoop.main)
            //If we don't succeed to receive FilmDetails it's ok
            //just to use initial film data
            .replaceError(with: film)
            .sink { [weak self] film in
                guard let self = self else { return }
                self.film = film
                
                guard let imageUrl = self.coverURL(for: film) else {
                    return
                }
                self.coverImageLoader.fetch(from: imageUrl)
            }.store(in: &bindings)
    }
    
    private func coverURL(for film: Film) -> URL? {
        let imageUrlString = film.coverUrl ?? film.posterUrl
        return URL(string: imageUrlString)
    }
}
