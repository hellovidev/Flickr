//
//  MultipartHelper.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation

enum MimeType: String {
    case imagePNG = "image/png"
}

struct MultipartHelper {
    
    private let boundary: String = "Boundary-\(UUID().uuidString)"
    private let parameters: [String: String]
    private let data: Data?
    
    init(parameters: [String: String], file data: Data? = nil) {
        self.parameters = parameters
        self.data = data
    }
    
    // Generate HTTP body for URL request
    func getRequestData() -> Data {
        var multipartFormData = Data()
        
        for (key, value) in parameters {
            let content: String = representingParameterAsFormField(filePathKey: key, value: value, using: boundary)
            multipartFormData.addContent(content)
        }
        
        if let fileData = data {
            let fileFormData = representingFileDataAsFormData(
                fieldName: "photo",
                fileName: "imagename.png",
                mimeType: .imagePNG,
                fileData: fileData,
                using: boundary
            )
            multipartFormData.append(fileFormData)
        }
        
        multipartFormData.addContent("--\(boundary)--")
        
        return multipartFormData
    }
    
    func getContentType() -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    private func representingParameterAsFormField(filePathKey: String, value: String, using boundary: String) -> String {
        var field = "--\(boundary)\r\n"
        
        field += "Content-Disposition: form-data; name=\"\(filePathKey)\"\r\n"
        field += "\r\n"
        field += "\(value)\r\n"
        
        return field
    }
    
    private func representingFileDataAsFormData(fieldName: String, fileName: String, mimeType: MimeType, fileData: Data, using boundary: String) -> Data {
        var data = Data()
        
        data.addContent("--\(boundary)\r\n")
        data.addContent("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.addContent("Content-Type: \(mimeType.rawValue)\r\n\r\n")
        data.append(fileData)
        data.addContent("\r\n")
        
        return data
    }
    
}

extension Data {
    mutating func addContent(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
