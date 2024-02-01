//
//  HTTPURLResponse+StatusCode.swift
//  Kinopoisk
//
//  Created by Toto on 10.01.2024.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return (200...299).contains(statusCode)
    }
}
