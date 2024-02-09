//
//  FilmCellViewModel.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation
import Combine

class ImageViewModel {
    @Published var imageData: Data?
    @Published var isImageLoading: Bool = false
    
    private var imageLoadingService = CacheImageLoader()
    private var imageLoadingBinding: AnyCancellable?
    
    private let imageURL: URL
    
    init(imageURL: URL) {
        self.imageURL = imageURL
        
        setUpBindings()
    }
    
    func cancelLoading() {
        imageLoadingService.cancelLoading()
        imageLoadingBinding = nil
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        imageLoadingBinding = imageLoadingService.$imageData
            .sink { [weak self] _ in
                self?.isImageLoading = false
            } receiveValue: { [weak self] data in
                if let imageData = data {
                    self?.imageData = imageData
                } else {
                    self?.imageData = nil
                    //TODO set placeholder image
                }
            }
        imageLoadingService.fetch(from: imageURL)
    }
}

final class FilmCellViewModel {
    @Published var title: String = ""
    @Published var description: String = ""
    
    private let film: Film
    
    private var dataLoadingBindings = Set<AnyCancellable>()
    
    private(set) var posterImageViewModel: ImageViewModel?
    
    init(film: Film) {
        if let url = URL(string: film.posterUrlPreview) {
            posterImageViewModel = ImageViewModel(imageURL: url)
        }
        
        self.film = film
        
        setUpBindings()
    }
    
    func cancelLoading() {
        posterImageViewModel?.cancelLoading()
        dataLoadingBindings.removeAll()
    }
    
    func checkViewModelIsFor(film: Film) -> Bool {
        return film == self.film
    }
    
    //MARK: Intrinsic logic
    private func setUpBindings() {
        title = film.nameRu ?? "Unnamed movie"
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
