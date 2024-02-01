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
    //MARK:  Data prepared to be displayed on interface
    @Published private(set) var state: ListViewModelState = InitialState.loadingState
    @Published private(set) var nextPageIsLoading: Bool = InitialState.nextPageIsLoading
    
    enum Section {
        case films
    }
    @Published private(set) var films: [Film] = InitialState.films
    
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
        guard state != .loading else { return }
        print("loadNextPageIfNeeded(\(lastRow)), lastRequestedPage = \(lastRequestedPage)")
        if lastRow >= films.count - 1 {
            loadNextPage()
        }
    }
    
    func reloadData() {
        resetToInitialState()
        loadNextPage()
    }
    
    //MARK: Logic
    private func loadNextPage() {
        if lastRequestedPage > 0 {
            nextPageIsLoading = true
        }
        lastRequestedPage = lastRequestedPage + 1
        loadLastRequestedPage()
    }
    
    private func loadLastRequestedPage() {
        state = .loading
        
        let loadingCompletionHandler: (Subscribers.Completion<ServiceError>) -> Void = { [weak self] completion in
            switch completion {
            case .failure:
                self?.state = .error
            case .finished:
                self?.state = .loadingFinished
            }
            self?.nextPageIsLoading = false
        }
        
        let pageLoadedHandler: ([Film]) -> Void = { [weak self] films in
            guard let self else { return }
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
        
        filmsService
            .get(page: lastRequestedPage)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: loadingCompletionHandler, receiveValue: pageLoadedHandler)
            .store(in: &bindings)
    }
}
