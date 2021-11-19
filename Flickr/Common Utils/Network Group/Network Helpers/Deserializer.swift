//
//  Deserializer.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 27.08.2021.
//

import Foundation

// MARK: - Deserializer

protocol Deserializer {
    associatedtype Response
    func parse(data: Data) throws -> Response
}

// MARK: - VoidDeserializer

struct VoidDeserializer: Deserializer {
    
    typealias Response = Void
    
    func parse(data: Data) throws -> Void {
        guard let response = String(data: data, encoding: .utf8) else { return }
        print("Server answer: \(response)")
    }
    
}

// MARK: - ModelDeserializer

struct ModelDeserializer<T: Decodable>: Deserializer {
    
    typealias Response = T
    
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }
    
    func parse(data: Data) throws -> T {
        do {
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            throw ErrorMessage.error("The server response could not be parsed into type of \(T.self).\nDescription: \(error)")
        }
    }
    
}

// MARK: - XMLDeserializer

class XMLStringDeserializer: NSObject, Deserializer, XMLParserDelegate {
    
    typealias Response = String
    
    var object: Response = .init()
    var currentElement: Bool = false
    
    func parse(data: Data) throws -> String {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return object
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "photoid" {
            currentElement = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement {
            object += string
            currentElement = false
        }
    }
    
}
