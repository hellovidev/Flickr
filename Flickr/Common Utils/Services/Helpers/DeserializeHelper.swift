//
//  DeserializeHelper.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import Foundation

protocol Deserializer {
    associatedtype Response
    func parse(data: Data) throws -> Response
}

struct VoidDeserializer: Deserializer {
    typealias Response = Void
    
    func parse(data: Data) throws -> Void {
        guard let response = String(data: data, encoding: .utf8) else { return }
        print("Server answer: \(response)")
    }
}
