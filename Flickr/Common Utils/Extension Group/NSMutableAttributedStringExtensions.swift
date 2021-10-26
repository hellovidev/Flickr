//
//  NSMutableAttributedStringExtensions.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.10.2021.
//

import UIKit

// MARK: - NSMutableAttributedString Extensions

extension NSMutableAttributedString {
    
    static func prepareContent(
        username: String?,
        usernameFontSize: CGFloat = 14,
        usernameFontWeight: UIFont.Weight = .bold,
        content: String?, contentFontSize: CGFloat = 14,
        contentFontWeight: UIFont.Weight = .regular
    ) -> NSMutableAttributedString {
        
        let usernameAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: usernameFontSize, weight: usernameFontWeight)
        ]
        
        let descriptionAttributedString = NSMutableAttributedString(string: username ?? "", attributes: usernameAttributes)
        
        let contentString = " " + (content ?? "")
        if let attributedString = contentString.htmlAttributedString {
            let contentAttributedString = NSMutableAttributedString(string: " ")
            contentAttributedString.append(NSAttributedString(attributedString: attributedString))
            descriptionAttributedString.append(contentAttributedString)
        }
        
        return descriptionAttributedString
    }
    
}
