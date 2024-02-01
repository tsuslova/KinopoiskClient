//
//  FilmsListViewModel.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation
import Combine

enum ListViewModelState {
    case loading
    case loadingFinished
    case error
}

final class FilmsListViewModel {
    @Published private(set) var films: [Film] = FilmsListViewModel.dummyFilmsList()
    @Published private(set) var state: ListViewModelState = .loadingFinished
    
    private var filmsService: FilmsService
    private var bindings = Set<AnyCancellable>()
    
    private var lastPageLoaded = KinopoiskDefaults.firstPage
    
    init(filmsService: FilmsService) {
        self.filmsService = filmsService
    }
    
    func loadFilms() {
        let loadingCompletionHandler: (Subscribers.Completion<ServiceError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .error
            case .finished:
                self?.state = .loadingFinished
            }
        }
        
        let pageLoadedHandler: ([Film]) -> Void = { [weak self] films in
            self?.films = films
        }
        
        self.filmsService.get(page: lastPageLoaded)
            .sink(receiveCompletion: loadingCompletionHandler, receiveValue: pageLoadedHandler)
            .store(in: &bindings)
    }
}
 
//Temporary test data
extension FilmsListViewModel {
    static func dummyFilmsList() -> [Film] {
        [Film(kinopoiskId: 0, nameRu: "Анна детективъ", posterUrl: "", posterUrlPreview: "")]
    }
}
