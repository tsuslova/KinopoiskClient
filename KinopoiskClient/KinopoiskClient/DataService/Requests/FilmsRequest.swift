//
//  FilmsRequest.swift
//  Kinopoisk
//
//  Created by Toto on 22.01.2024.
//

import Foundation

struct FilmsRequest: CompactDictionaryRepresentable {
    let page: Int

    init(page: Int) {
        self.page = page
    }
}
