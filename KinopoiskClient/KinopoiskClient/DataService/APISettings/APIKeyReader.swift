//
//  APIKeyReader.swift
//  Kinopoisk
//
//  Created by Toto on 04.01.2024.
//

import Foundation

final class APIKeyReader {
    static var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist.object(forKey: "APIKey") as? String,
              value.count > 0
        else {
              //Please fill-in the APIKey provided by developer(Tamara) here
              //Or generate your own on https://kinopoiskapiunofficial.tech
              return ""
        }
        return value
    }
}
