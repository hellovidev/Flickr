//
//  SignatureHelper.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 26.08.2021.
//

import Foundation
import CommonCrypto

struct SignatureHelper {
    
    private let consumerSecretKey: String
    private var accessSecretToken: String?
    
    init(consumerSecretKey: String, accessSecretToken: String?) {
        self.consumerSecretKey = consumerSecretKey
        self.accessSecretToken = accessSecretToken
    }
    
    mutating func setNewAccessSecretToken(_ accessSecretToken: String) {
        self.accessSecretToken = accessSecretToken
    }
    
    func buildSignature(method: String, endpoint: String, parameters: [String: String]) -> String {
        // Initialization 'Signing Key'
        var signingKey = self.consumerSecretKey + "&"
        if let secretToken = self.accessSecretToken {
            signingKey += secretToken
        }
        
        // Initialization 'Signing Base'
        let stringParameters = convertParametersToString(parameters, separator: "&")
        let baseSignature = method + "&" + encodeString(endpoint) + "&" + encodeString(stringParameters)
        
        // Build 'Signature' using HMAC-SHA1
        let sign = baseSignature.hmac(algorithm: .SHA1, key: signingKey)//hashMessageAuthenticationCodeSHA1(signingKey: signingKey, baseSignature: baseSignature)
        print("Defore: \(sign)")
        
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "+")
        let s = sign.addingPercentEncoding(withAllowedCharacters: charset)!
        print(s)
        return s
    }
    
    // Prepare string value to signature view: 'https://www.flickr.com/services/oauth/request_token' => 'https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token'
    private func encodeString(_ value: String) -> String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return value.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    
    // HMAC-SHA1 method to create signature, HMAC-SHA1 hashing algorithm returned as a base64 encoded string
    private func hashMessageAuthenticationCodeSHA1(signingKey: String, baseSignature: String) -> String {
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
    
}


enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, strlen(cKey!), cData!, strlen(cData!), &result)
        var hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        var hmacBase64 = hmacData.base64EncodedString(options: .lineLength76Characters)
        return hmacBase64
    }
}
