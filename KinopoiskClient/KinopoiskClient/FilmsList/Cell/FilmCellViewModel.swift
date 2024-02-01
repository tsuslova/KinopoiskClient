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
    
    private var dataLoadingBindings = Set<AnyCancellable>()
    
    //TODO: this dependency should be injected from outside...
    var imageLoadingService: ImageLoader = RemoteImageLoader(client: URLSessionHTTPClient())
    
    init(film: Film) {
        self.film = film
        
        setUpBindings()
    }
    
    func cancelLoading() {
        dataLoadingBindings.removeAll()
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        title = film.nameRu ?? "Unnamed movie"
        fillDescription()
        
        guard let url = URL(string: film.posterUrlPreview) else {
            print("Error: wrong posterUrlPreview (\(film.posterUrlPreview))")
            return
        }
        imageLoadingService.get(from: url)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isImageLoading = false
            } receiveValue: { [weak self] data in
                self?.posterImageData = data
            }.store(in: &dataLoadingBindings)
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
