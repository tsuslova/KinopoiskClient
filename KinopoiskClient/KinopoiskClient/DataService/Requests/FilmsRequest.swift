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
    
    //At the moment I'm using page only
    //TODO: add some more configurable parameters as soon as they are needed
//    struct FilmsRequestParameters: Encodable{
//        let order = "RATING"
//        let type = "ALL"
//        let ratingFrom = 0
//        let ratingTo = 10
//        let yearFrom = 2000
//        let yearTo = 2023
//
//        let page: Int
//
//        init(page: Int){
//            self.page = page
//        }
//    }

}
