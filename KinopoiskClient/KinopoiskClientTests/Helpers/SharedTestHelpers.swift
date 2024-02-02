//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Toto on 22.08.2023.
//

import Foundation

func anyNSError(_ domain: String = "any error") -> NSError {
    NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
