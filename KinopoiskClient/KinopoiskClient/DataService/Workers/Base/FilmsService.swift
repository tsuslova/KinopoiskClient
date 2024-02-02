//
//  FilmsService.swift
//  Kinopoisk
//
//  Created by Toto on 20.07.2023.
//

import Foundation
import Combine

protocol FilmsService {
    func get(page: Int, keyword: String?) -> AnyPublisher<[Film], ServiceError>
}
