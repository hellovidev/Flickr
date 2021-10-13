//
//  ArrayExtension.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 13.10.2021.
//

import Foundation

// MARK: - Array Extensions

extension Array where Element: Hashable {
    
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
}
