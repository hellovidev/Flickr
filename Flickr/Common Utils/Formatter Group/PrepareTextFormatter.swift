//
//  PrepareTextFormatter.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 12.10.2021.
//

import Foundation

struct PrepareTextFormatter {
    
    enum Placeholder: String {
        case location = "No location"
        case title = "No title"
        case description = "No description"
        case date = "No date"
        case name = "No name"
        case username = "No username"
    }
    
    static func prepareUserLocation(_ location: String?) -> String {
        guard
            let location = location,
                !location.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return Placeholder.location.rawValue
        }
        
        return location
    }
    
    static func prepareUserAccountName(name: String?, username: String?) -> String {
        var accountName: String = .init()
        
        if
            let name = name,
                !name.trimmingCharacters(in: .whitespaces).isEmpty
        {
            accountName.append(name)
        } else {
            accountName.append(Placeholder.name.rawValue)
        }
        
        if
            let username = username,
                !username.trimmingCharacters(in: .whitespaces).isEmpty
        {
            accountName.append(" (\(username))")
        } else {
            accountName.append(" (\(Placeholder.username.rawValue))")
        }
        
        return accountName
    }
    
    static func prepareTextField(_ input: String?, placeholder: Placeholder) -> String {
        guard
            let input = input, !input.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return placeholder.rawValue
        }
        
        return input
    }
    
}
