//
//  NetworkService.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.08.2021.
//

import Foundation

// MARK: - API Access Structure

struct AccessTokenAPI {
    let token: String
    let secret: String
    let nsid: String
}

// MARK: - Network Layer (REST)

class NetworkService {
    
    // Methods to prepare API requests
    private let prepare: RequestPreparation = .init()
    
    // Token to get access to 'Flickr API'
    private let access: AccessTokenAPI
    
    // Without access token 'NetworkService' do not work
    init(withAccess accessToken: AccessTokenAPI) {
        self.access = accessToken
    }
    
    // MARK: - Response Decoders Entities
    
    /*
     Response: ["message": Invalid NSID provided, "code": 1, "stat": fail]
     */
    
    private struct ErrorResponse: Decodable {
        let message: String
        let code: Int
    }
    
    private struct ProfileResponse: Decodable {
        let profile: Profile
    }
    
    private struct CommentsResponse: Decodable {
        let data: Comments
        
        fileprivate struct Comments: Decodable {
            let comments: [Comment]
            
            enum CodingKeys: String, CodingKey {
                case comments = "comment"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case data = "comments"
        }
    }
    
    private struct FavoritesResponse: Decodable {
        let data: Favorites
        
        fileprivate struct Favorites: Decodable {
            let photos: [Favorite]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
    private struct PhotosResponse: Decodable {
        let data: Photos
        
        fileprivate struct Photos: Decodable {
            let photos: [Photo]
            
            enum CodingKeys: String, CodingKey {
                case photos = "photo"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case data = "photos"
        }
    }
    
    private struct TagsResponse: Decodable {
        let data: Tags
        
        fileprivate struct Tags: Decodable {
            let tag: [Tag]
            
            enum CodingKeys: String, CodingKey {
                case tag = "tag"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case data = "hottags"
        }
    }
    
    
    // MARK: - Special Methods
    
    // Get current user profile 'flickr.profile.getProfile' (User screen)
    func getProfile(complition: @escaping (Result<Profile, Error>) -> Void) {
        let parameters: [String: String] = [
            "user_id": access.nsid
        ]
        
        request(params: parameters, requestMethod: .getProfile, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                // Initialization decoder
                let decoder = JSONDecoder()
                
                // Decode with 'snake_case' strategy
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let response = try decoder.decode(ProfileResponse.self, from: data)
                    complition(.success(response.profile))
                } catch {
                    complition(.failure(ErrorMessage.error("Profile data could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Get photo comments list 'flickr.photos.comments.getList' (Post screen)
    func getPhotoComments(for photoId: String, complition: @escaping (Result<[Comment], Error>) -> Void) {
        let parameters: [String: String] = [
            "photo_id": photoId
        ]
        
        request(params: parameters, requestMethod: .getComments, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    // Initialization decoder
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(CommentsResponse.self, from: data)
                    complition(.success(response.data.comments))
                } catch {
                    complition(.failure(ErrorMessage.error("Comments of photo with id(\(photoId) could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Get list of faves 'flickr.favorites.getList' (Gallery screen)
    func getFavorites(complition: @escaping (Result<[Favorite], Error>) -> Void) {
        request(requestMethod: .getFavorites, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    // Initialization decoder
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(FavoritesResponse.self, from: data)
                    complition(.success(response.data.photos))
                } catch {
                    complition(.failure(ErrorMessage.error("Favorites could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Get list of popular photos 'flickr.photos.getPopular' (General screen)
    func getPopularPosts(complition: @escaping (Result<[Photo], Error>) -> Void) {
        request(requestMethod: .getPopularPosts, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    // Initialization decoder
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PhotosResponse.self, from: data)
                    complition(.success(response.data.photos))
                } catch {
                    complition(.failure(ErrorMessage.error("Popular photos could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    // Get list of hot tags 'flickr.places.tagsForPlace' (General screen)
    func getHotTags(count: Int, complition: @escaping (Result<[Tag], Error>) -> Void) {
        let parameters: [String: String] = [
            "count": String(count)
        ]
        
        request(params: parameters, requestMethod: .getHotTags, path: .requestREST, method: .GET) { result in
            switch result {
            case .success(let data):
                do {
                    // Initialization decoder
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TagsResponse.self, from: data)
                    complition(.success(response.data.tag))
                } catch {
                    complition(.failure(ErrorMessage.error("Tags could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func postNewPhoto(photoId: String, title: String, description: String, complition: @escaping (String) -> Void) {
        let parameters: [String: String] = [
            "photo_id": photoId,
            "title": title,
            "description": description,
            "perms": "write",
            "blog_id": UUID().uuidString
        ]
        
        request(params: parameters, requestMethod: .postPhoto, path: .requestREST, method: .POST) { result in
            switch result {
            case .success(let data):
                do {
                    // Initialization decoder
                    guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                    print("Response: \(response)")
                    //complition(.success(response.data.comments))
                } catch {
                    //complition(.failure(ErrorMessage.error("Comments of photo with id(\(photoId) could not be parsed.\nDescription: \(error)")))
                }
            case .failure(let error):
                print("ERROR !!! \(error)")
            //complition(.failure(error))
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     //
     //
     //
     //    Photo uploading link and(?) flickr.blogs.postPhoto
     */
    
    //    func testLoginRequest() {
    //        let parameters: [String: String] = [
    //            "nojsoncallback": "1",
    //            "format": "json",
    //            "oauth_token": access.token,
    //            "method": "flickr.test.login"
    //        ]
    //
    //        request(params: parameters, requestMethod: <#Constant.FlickrMethod#>, path: .requestREST, method: .GET) { result in
    //            switch result {
    //            case .success(let data):
    //                do {
    //                    guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
    //                    print("Response: \(response)")
    //                } catch(let error) {
    //                    print("Data couldn't be parsed: \(error.localizedDescription)")
    //                }
    //            case .failure(let error):
    //                print("Get 'flickr.test.login' error: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    
    // MARK: - Foundation Methods
    
    private func request(params extraParameters: [String: String]? = nil, requestMethod: Constant.FlickrMethod, path: HttpEndpoint.PathType, method: HttpMethodType, complition: @escaping (Result<Data, Error>) -> Void) {
        // Build base URL with path as parameter
        let urlString = HttpEndpoint.baseDomain.rawValue + path.rawValue
        
        var parameters: [String: String] = [
            "nojsoncallback": "1",
            "format": "json",
            "oauth_token": access.token,
            "method": requestMethod.rawValue,
            "oauth_consumer_key": FlickrAPI.consumerKey.rawValue,
            // Value 'nonce' can be any 32-bit string made up of random ASCII values
            "oauth_nonce": UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        
        // Add to parameters extra values
        if let extraParameters = extraParameters {
            parameters = parameters.merging(extraParameters) { (current, _) in current }
        }
        
        // Build the OAuth signature from parameters
        parameters["oauth_signature"] = prepare.createRequestSignature(httpMethod: method.rawValue, url: urlString, parameters: parameters, secretToken: access.secret)
        
        // Set parameters to request
        
        var components = URLComponents(string: urlString)
        components?.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        // Initialize and configure URL request
        guard let url = components?.url else { return }
        var urlRequest = URLRequest(url: url)
        
        // Set HTTP method to request using HttpMethodType with uppercase letters
        urlRequest.httpMethod = method.rawValue
        
        // URL configuration
        let config = URLSessionConfiguration.default
        
        // Request creation
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                complition(.failure(FlickrOAuthError.responseIsEmpty))
                return
            }
            
            guard let data = data else {
                complition(.failure(FlickrOAuthError.dataIsEmpty))
                return
            }
            
            if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                complition(.failure(ErrorMessage.error("Error: \(error.message)")))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.success(data))
            case ..<500:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.failure(FlickrOAuthError.invalidSignature))
            case ..<600:
                print("Status Code: \(httpResponse.statusCode)\nMessage: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                complition(.failure(FlickrOAuthError.serverInternalError))
            default:
                print("Unknown status code!")
                complition(.failure(FlickrOAuthError.unexpected(code: httpResponse.statusCode)))
            }
            
        }
        
        // Start request process
        task.resume()
    }
    
}





//switch self {
//case .dataCanNotBeParsed:
//    return "Response data can not be parsed."
//case .responseIsEmpty:
//    return "Response from server is empty."
//case .dataIsEmpty:
//    return "Data from server is empty."
//case .invalidSignature:
//    return "Invalid 'HMAC-SHA1' signature."
//case .serverInternalError:
//    return "Internal server error."
//case .unexpected(_):
//    return "An unexpected error occurred."
//}



//switch httpResponse.statusCode {
//case ..<200:
//    complition(.failure(ErrorMessage.error("Informational message error (\(httpResponse.statusCode)).")))
//case ..<300:
//    print("Status: \(httpResponse.statusCode) OK")
//    complition(.success(data))
//case ..<400:
//    complition(.failure(ErrorMessage.error("Redirection message (\(httpResponse.statusCode)).")))
//case ..<500:
//    complition(.failure(ErrorMessage.error("Client request error (\(httpResponse.statusCode)).")))
//case ..<600:
//    complition(.failure(ErrorMessage.error("Internal server error (\(httpResponse.statusCode)).")))
//default:
//    complition(.failure(ErrorMessage.error("Unknown status code (\(httpResponse.statusCode)).")))
//}










// to generate link https://www.flickr.com/services/api/misc.urls.html
/*
 
 
 #
 # Typical usage
 #
 
 https://live.staticflickr.com/{server-id}/{id}_{secret}_{size-suffix}.jpg
 
 #
 # Unique URL format for 500px size
 #
 
 https://live.staticflickr.com/{server-id}/{id}_{secret}.jpg
 
 #
 # Originals might have a different file format extension
 #
 
 https://live.staticflickr.com/{server-id}/{id}_{o-secret}_o.{o-format}
 
 #
 # Example
 #   server-id: 7372
 #   photo-id: 12502775644
 #   secret: acfd415fa7
 #   size: w
 #
 
 https://live.staticflickr.com/7372/12502775644_acfd415fa7_w.jpg
 
 */
