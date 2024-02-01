//
//  SearchFilmsRequest.swift
//  Kinopoisk
//
//  Created by Toto on 29.01.2024.
//

import Foundation

struct SearchFilmsRequest: CompactDictionaryRepresentable {
    let page: Int
    let keyword: String
    
    init(page: Int, keyword: String) {
        self.page = page
        self.keyword = keyword
    }
}
