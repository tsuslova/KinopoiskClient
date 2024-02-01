//
//  FilmsListViewModel.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation

enum ListViewModelState {
    case loading
    case loadingFinished
    case error
}

final class FilmsListViewModel {
    @Published private(set) var films: [Film] = FilmsListViewModel.dummyFilmsList()
    @Published private(set) var state: ListViewModelState = .loadingFinished
}
 
//Temporary test data
extension FilmsListViewModel {
    static func dummyFilmsList() -> [Film] {
        [Film(kinopoiskId: 0, nameRu: "Анна детективъ", posterUrl: "", posterUrlPreview: "")]
    }
}
