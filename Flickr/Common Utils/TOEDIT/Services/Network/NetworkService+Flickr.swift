//
//  NetworkService+Flickr.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 06.09.2021.
//

import Foundation

extension NetworkService {
    
    func request<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        type: FlickrConstant.Method,
        method: HTTPMethod,
        parser: Serializer,
        completion: @escaping (Result<Serializer.Response, Error>) -> Void
    ) {
        request(
            parameters: parameters,
            type: type.rawValue,
            endpoint: FlickrConstant.URL.request.rawValue,
            method: method,
            parser: parser,
            completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        )
    }
    
    func upload<Serializer: Deserializer>(
        parameters: [String: String]? = nil,
        file: Data,
        parser: Serializer,
        completion: @escaping (Result<Serializer.Response, Error>) -> Void
    ) {
        upload(
            parameters: parameters,
            file: file,
            endpoint: FlickrConstant.URL.upload.rawValue,
            parser: parser,
            completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        )
    }
    
}
