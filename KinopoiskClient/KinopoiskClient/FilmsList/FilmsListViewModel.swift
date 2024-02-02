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
    case error(_ error: Error)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

final class FilmsListViewModel {
    //MARK:  Data prepared to be displayed on interface
    @Published private(set) var state: ListViewModelState = InitialState.loadingState
    @Published private(set) var nextPageIsLoading: Bool = InitialState.nextPageIsLoading
    
    enum Section {
        case films
    }
    @Published private(set) var films: [Film] = InitialState.films
    
    private var searchedText: String?
    
    //MARK: Initialization
    private var filmsService: FilmsService
    private var bindings = Set<AnyCancellable>()
    
    private(set) var lastRequestedPage: Int = InitialState.pageBeforeFirst
    
    init(filmsService: FilmsService) {
        self.filmsService = filmsService
    }
    
    private func resetToInitialState() {
        state = InitialState.loadingState
        nextPageIsLoading = InitialState.nextPageIsLoading
        lastRequestedPage = InitialState.pageBeforeFirst
        films = InitialState.films
    }
    
    //We need a way to re-initialise the viewmodel but we cannot use initializer
    //method from init. To avoid constants duplication and to make them more verbose
    //move them to InitialState
    private struct InitialState {
        static let loadingState: ListViewModelState = .loadingFinished
        static let nextPageIsLoading = false
        static let pageBeforeFirst = KinopoiskDefaults.firstPage - 1
        static let films: [Film] = []
    }
    
    //MARK: Interface
    func loadNextPageIfNeeded(for lastRow: Int) {
        //For simplification assume for the moment that we load pages one by one
        //(interface doesn't provide an ability for accessing pages in non-sequential way)
        guard !state.isLoading else { return }
        print("loadNextPageIfNeeded(\(lastRow)), lastRequestedPage = \(lastRequestedPage)")
        if lastRow >= films.count - 1 {
            loadNextPage()
        }
    }
    
    func reloadData(for text: String? = nil) {
        resetToInitialState()
        searchedText = text
        loadNextPage()
    }
    
    func search(text: String?) {
        guard text != searchedText else {
            print("Already searched for \(searchedText ?? "")")
            return
        }
        guard text != nil || searchedText == nil else {
            print("Nothing to be done")
            return
        }
        reloadData(for: text)
    }
    
    //MARK: Logic
    
    private func loadNextPage() {
        if lastRequestedPage > 0 {
            nextPageIsLoading = true
        }
        lastRequestedPage = lastRequestedPage + 1
        
        loadLastRequestedPage()
    }
    
    private func handleLoadingCompletion(_ completion: Subscribers.Completion<ServiceError>) {
        switch completion {
        case .failure(let error):
            state = .error(error)
        case .finished:
            state = .loadingFinished
        }
        nextPageIsLoading = false
    }
    
    private func handlePageLoading(films: [Film]) {
        var currentList = self.films
        for film in films {
            //Kinopoisk API might return the same items on different pages
            //to avoid strange behaviour and crashes skip them
            if !currentList.contains(film) {
                currentList.append(film)
            }
        }
        self.films = currentList
    }
    
    private func loadLastRequestedPage() {
        state = .loading
        
        filmsService
            .get(page: lastRequestedPage, keyword: searchedText)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleLoadingCompletion(completion)
            }, receiveValue: { [weak self] films in
                self?.handlePageLoading(films: films)
            })
            .store(in: &bindings)
    }
}
