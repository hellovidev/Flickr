//
//  DeserializeHelper.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import Foundation

private protocol Deserializer {
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

struct ModelDeserializer<T: Decodable>: Deserializer {
    typealias Response = T
        
    func parse(data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            throw ErrorMessage.error("The server response could not be parsed into type of \(T.self).\nDescription: \(error)")
        }
    }
}
