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
    
    @Published private(set) var shortDescription: String?
    @Published private(set) var description: String?
    
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
    
    //MARK: Data preparation to display in interface
    func rating(for film: Film?) -> String {
        if let rating = film?.ratingKinopoisk {
            return String(format: "%.1f", rating)
        } else {
            return ""
        }
    }
    
    func ratingTextColor(for film: Film?) -> UIColor {
        guard let rating = film?.ratingKinopoisk else {
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

    func ratingVoteCount(for film: Film?) -> String {
        guard let ratingVoteCount = film?.ratingVoteCount, ratingVoteCount > 0 else {
            return ""
        }
        let ratingVoteCountShorten: String
        if ratingVoteCount > 1000000 {
            ratingVoteCountShorten = "\(ratingVoteCount / 1000000)M"
        } else if ratingVoteCount > 1000 {
            ratingVoteCountShorten = "\(ratingVoteCount / 1000)K"
        } else {
            ratingVoteCountShorten = "\(ratingVoteCount)"
        }
        return ratingVoteCountShorten
    }
    
    func showDescriptionCell(for film: Film) -> Bool {
        return (film.shortDescription?.count ?? 0) > 0 ||
            (film.description?.count ?? 0) > 0
    }
    
    func yearGenres(for film: Film) -> String {
        let genres = "\(film.genres.joined(separator: ", "))"
        
        let yearString: String
        if let year = film.year {
            yearString = "\(year)"
        } else {
            yearString = ""
        }
        return [yearString, genres].joined
    }
    
    func countryLength(for film: Film) -> String {
        let countries = "\(film.countries.joined(separator: ", "))"
        
        var lengthString: String
        if let length = film.filmLength {
            lengthString = length > 60 ?
                "\(length/60)ч \(length % 60) мин" :
                "\(length) мин"
        } else {
            lengthString = ""
        }
        let limits = film.ratingAgeLimits
        return [countries, lengthString].joined
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
                
                self.shortDescription = film.shortDescription
                self.description = film.description
                
                self.loadImages()
            }.store(in: &bindings)
    }
    
    private func loadImages() {
        loadCoverImage()
        
        loadLogo()
    }
    
    private func loadCoverImage() {
        guard let imageUrl = self.coverURL(for: film) else {
            return
        }
        self.coverImageLoader.fetch(from: imageUrl)
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

//MARK: - Helpers
private extension Array where Element == String {
    
    var joined: String {
        return "\(self.filter { !$0.isEmpty }.joined(separator: ", "))"
    }
}
