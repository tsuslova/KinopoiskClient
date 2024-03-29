// Copyright © 2023 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev on 20.01.2023.

import Foundation

/// Протокол для представления структур в виде словаря, при этом удаляются все поля = nil
/// Применяется для формирования параметров HTTP GET запросов.
public protocol CompactDictionaryRepresentable {
    var compactDictionaryRepresentation: [String: Any] { get }
}

public extension CompactDictionaryRepresentable {
    var compactDictionaryRepresentation: [String: Any] {
        let children: [(String?, Any?)] = Array(Mirror(reflecting: self).children)
        return Dictionary(
            uniqueKeysWithValues: children.compactMap {
                ($0.0 == nil || $0.1 == nil) ? nil : ($0.0!, $0.1!)
            }
        )
    }
}

public extension Dictionary where Key == String {
    var urlQueryItems: [URLQueryItem] {
        map { .init(name: $0, value: String(describing: $1)) }
    }
}
