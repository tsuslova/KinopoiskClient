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
    //TODO the dependency to be injected
    private var imageLoadingService = CacheImageLoader()
    
    init(film: Film) {
        self.film = film
    }
}
