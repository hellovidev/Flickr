//
//  StringExtensions.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.10.2021.
//

import Foundation

// MARK: - String Extensions

extension String {
    
    func prepareStringAsDate(format: String = "dd MMM yyyy") -> String? {
        guard let dateAsIntSince1970 = Int(self) else { return nil }
        let date: Date = Date(timeIntervalSince1970: TimeInterval(dateAsIntSince1970))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let formattedDateAsString = dateFormatter.string(from: date)
        return formattedDateAsString
    }
    
}

extension String {
    
    var htmlAttributedString: NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 14px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """
        
        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }
        
        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) else {
            return nil
        }
        
        return attributedString
    }
    
}
