//
//  RequestPreparation.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.08.2021.
//

import Foundation
import CommonCrypto

// MARK: - Request Preparation Methods

class RequestPreparation {
    
    // Prepare string value to signature view: 'https://www.flickr.com/services/oauth/request_token' => 'https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token'
    func encodeString(_ value: String) -> String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return value.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
    // HMAC-SHA1 method to create signature, HMAC-SHA1 hashing algorithm returned as a base64 encoded string
    func hashMessageAuthenticationCodeSHA1(signingKey: String, baseSignature: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, baseSignature, baseSignature.count, &digest)
        return Data(digest).base64EncodedString()
    }
    
    func convertParametersToString(_ parameters: [String: Any], separator: String) -> String {
        var result: [String] = []
        for parameter in parameters {
            let key = parameter.key
            let value = encodeString("\(parameter.value)")
            result.append("\(key)=\(value)")
        }
        return result.sorted().joined(separator: separator)
    }
    
    func createRequestSignature(httpMethod: String, url: String, parameters: [String: Any], consumerSecretKey: String = FlickrAPI.consumerSecretKey.rawValue, secretToken: String? = nil) -> String {
        // Initialization 'Signing Key'
        var signingKey = consumerSecretKey + "&"
        if let secretToken = secretToken {
            signingKey += secretToken
        }
        
        // Initialization 'Signing Base'
        let stringParameters = convertParametersToString(parameters, separator: "&")
        let baseSignature = httpMethod + "&" + encodeString(url) + "&" + encodeString(stringParameters)
        
        // Build 'Signature' using HMAC-SHA1
        return hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: baseSignature)
    }
    
}
