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
    @Published var imageData: Data?
    
    private let film: Film
    
    private var dataLoadingBindings = Set<AnyCancellable>()
    
    private var posterImageLoader: CacheImageLoader?
    
    init(film: Film) {
        self.film = film
        
        if let url = URL(string: film.posterUrlPreview) {
            posterImageLoader = CacheImageLoader()
            posterImageLoader?.fetch(from: url)
        }
        
        setUpBindings()
    }
    
    func cancelLoading() {
        posterImageLoader?.cancelLoading()
        dataLoadingBindings.removeAll()
    }
    
    func checkViewModelIsFor(film: Film) -> Bool {
        return film == self.film
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        title = film.nameRu ?? "Unnamed movie"
        posterImageLoader?.$imageData
            .receive(on: RunLoop.main)
            .assign(to: &$imageData)
        
        fillDescription()
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
