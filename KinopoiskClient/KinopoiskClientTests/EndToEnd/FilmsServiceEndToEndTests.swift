//
//  FilmsServiceEndToEndTests.swift
//  KinopoiskClientTests
//
//  Created by Toto on 04.01.2024.
//

import XCTest
import Combine
@testable import KinopoiskClient

final class FilmsServiceEndToEndTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        checkForAPIKey()
        cancellables = []
    }

    func test_endToEndGETFilmsResult_returnsSomeFilms() {
        let loader = RemoteFilmsService(client: ephemeralClient())
        trackForMemoryLeaks(loader)
        
        var error: Error?
        let exp = expectation(description: "Wait for load completion")
        var films: [Film]?
        
        loader.get(page: KinopoiskDefaults.firstPage)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let receivedError):
                    error = receivedError
                }
                exp.fulfill()
            } receiveValue: { receivedFilms in
                films = receivedFilms
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(error)
        XCTAssertNotEqual(films?.count ?? 0, 0)
    }
    
    func test_endToEndGetFilmDetails_returnsValidFilm() {
        let loader = RemoteFilmsService(client: ephemeralClient())
        trackForMemoryLeaks(loader)
        
        var error: Error?
        let exp = expectation(description: "Wait for load completion")
        var film: Film?
        
        let filmId = 301
        
        loader.getDetails(filmId: filmId)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let receivedError):
                    error = receivedError
                }
                exp.fulfill()
            } receiveValue: { receivedFilm in
                film = receivedFilm
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertNil(error)
        XCTAssertEqual(film?.kinopoiskId ?? 0, filmId)
    }
    
    // MARK: - Helpers
    func checkForAPIKey() {
        if APIKeyReader.apiKey == "" {
            fatalError("Please fill-in the APIKey provided by developer(Tamara) in APIKeyReader class. Or generate your own on https://kinopoiskapiunofficial.tech")
        }
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(configuration: .ephemeral)
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
}
