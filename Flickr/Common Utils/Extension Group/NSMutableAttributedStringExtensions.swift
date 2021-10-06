//
//  NSMutableAttributedStringExtensions.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.10.2021.
//

import UIKit

extension NSMutableAttributedString {
    
    static func prepareContent(username: String?, usernameFontSize: CGFloat = 14, usernameFontWeight: UIFont.Weight = .bold, content: String?, contentFontSize: CGFloat = 14, contentFontWeight: UIFont.Weight = .regular) -> NSMutableAttributedString {
        
        let usernameAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: usernameFontSize, weight: usernameFontWeight)
        ]
        
        let contentAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: contentFontSize, weight: contentFontWeight)
        ]
        
        let descriptionAttributedString = NSMutableAttributedString(string: username ?? "", attributes: usernameAttributes)
        let contentAttributedString = NSAttributedString(string: " " + (content ?? ""), attributes: contentAttributes)
        descriptionAttributedString.append(contentAttributedString)
        
        return descriptionAttributedString
    }
    
}
