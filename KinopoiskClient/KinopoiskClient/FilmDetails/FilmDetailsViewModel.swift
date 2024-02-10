//
//  FilmDetailsViewModel.swift
//  KinopoiskClient
//
//  Created by Toto on 02.02.2024.
//

import Foundation
import Combine
import UIKit.UIColor

final class FilmDetailsViewModel {
    @Published private(set) var film: Film
    @Published private(set) var coverImageData: Data?
    
    @Published private(set) var logoImageData: Data?
    //If logo image is not available display the replacing text info:
    @Published private(set) var logoReplacingText: String?
    
    private var filmsService: FilmsService
    private var bindings = Set<AnyCancellable>()
    
    private var coverImageLoader = CacheImageLoader()
    private var logoImageLoader = CacheImageLoader()
    
    //MARK: Interface
    init(film: Film, filmsService: FilmsService) {
        self.film = film
        self.filmsService = filmsService
    }
    
    func loadFilmDetails() {
        setUpBindings()
        loadFilmDetailsData()
    }
    
    func rating() -> String {
        if let rating = film.ratingKinopoisk {
            return String(format: "%.1f", rating)
        } else {
            return ""
        }
    }
    
    func ratingTextColor() -> UIColor {
        guard let rating = film.ratingKinopoisk else {
            return .darkGray //Default
        }
        //Imitation of current Kinopoisk behaviour(normally should be configured on server-side):
        if rating >= 7 {
            return .green
        } else if rating <= 4 {
            return .red
        } else {
            return .darkGray
        }
    }

    //MARK: Intrinsic logic
    private func setUpBindings() {
        coverImageLoader.$imageData
            .receive(on: RunLoop.main)
            .assign(to: &$coverImageData)
        
        logoImageLoader.$imageData
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let data = data else {
                    self?.fillLogoReplacingInfo()
                    return
                }
                self?.logoImageData = data
                self?.logoReplacingText = nil
            }.store(in: &bindings)
    }
    
    private func loadFilmDetailsData() {
        filmsService.getDetails(filmId: film.kinopoiskId)
            .receive(on: RunLoop.main)
            //If we don't succeed to receive FilmDetails it's ok
            //just to use initial film data
            .replaceError(with: film)
            .sink { [weak self] film in
                guard let self else { return }
                self.film = film
                
                self.loadImages()
            }.store(in: &bindings)
    }
    
    private func loadImages() {
        guard let imageUrl = self.coverURL(for: film) else {
            return
        }
        self.coverImageLoader.fetch(from: imageUrl)
        
        loadLogo()
    }
    
    private func coverURL(for film: Film) -> URL? {
        let imageUrlString = film.coverUrl ?? film.posterUrl
        return URL(string: imageUrlString)
    }
    
    private func loadLogo() {
        guard let logoUrlString = film.logoUrl,
              let logoUrl = URL(string: logoUrlString) else {
            fillLogoReplacingInfo()
            return
        }
        logoImageLoader.fetch(from: logoUrl)
    }
    
    private func fillLogoReplacingInfo() {
        logoReplacingText = (film.nameRu ?? film.nameOriginal ?? "Unnamed movie")?.uppercased()
    }
}
