//
//  FilmCellViewModel.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation
import Combine

final class FilmCellViewModel {
    @Published var title: String = ""
    @Published var description: String = ""
        
    @Published var posterImageData: Data?
    @Published var isImageLoading: Bool = false
    
    private let film: Film
    private var imageLoadingService = CacheImageLoader()
    
    private var dataLoadingBindings = Set<AnyCancellable>()
    
    init(film: Film) {
        self.film = film
        
        setUpBindings()
    }
    
    func cancelLoading() {
        dataLoadingBindings.removeAll()
    }
    
    func checkViewModelIsFor(film: Film) -> Bool {
        return film == self.film
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        title = film.nameRu ?? "Unnamed movie"
        fillDescription()
        
        imageLoadingService.$imageData
            .sink { [weak self] _ in
                self?.isImageLoading = false
            } receiveValue: { [weak self] data in
                if let imageData = data {
                    self?.posterImageData = imageData
                } else {
                    self?.posterImageData = nil
                    //TODO set placeholder image
                }
            }.store(in: &dataLoadingBindings)
        
        if let url = URL(string: film.posterUrlPreview) {
            imageLoadingService.fetch(from: url)
        }
    }
    
    private func fillDescription() {
        let countries = film.countries.shortenTo3Words
        let genres = film.genres.shortenTo3Words
        
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
    var shortenTo3Words: String {
        self.count > 3 ?
            "\(self[0..<3].joined(separator: ", "))[...]" :
            "\(self.joined(separator: ", "))"
    }
}
