//
//  NetworkDataManagerService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import Foundation

struct NetworkDataManagerService {
    
    let network: NetworkService
    let cache: CacheStorageService
    
    init(_ token: AccessTokenAPI) {
        self.network = .init(token: token, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
        self.cache = .init()
    }
    
}
