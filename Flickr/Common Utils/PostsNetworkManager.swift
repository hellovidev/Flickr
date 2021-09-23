//
//  PostsNetworkManager.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 19.09.2021.
//

import UIKit

enum NetworkManagerError: Error {
    case invalidParameters
}

enum ResponseSource {
    case cache
    case network
}

struct PostImage {
    let image: UIImage
    let type: ResponseSource
}

struct PostInformation {
    let information: PostDetails
    let type: ResponseSource
}

class PostsNetworkManager {
    
    private let networkService: NetworkService
    private let cacheImages: CacheStorageService<NSString, UIImage>
    private let cacheBuddyicons: CacheStorageService<NSString, UIImage>
    private let cachePostInformation: CacheStorageService<NSString, PostDetails>
    
    private var ids: [String]
    private var page: Int
    private var perPage: Int = 20
    
    var idsCount: Int {
        ids.count
    }
    
    init(_ token: AccessTokenAPI) {
        self.networkService = .init(token: token, publicKey: FlickrConstant.Key.consumerKey.rawValue, secretKey: FlickrConstant.Key.consumerSecretKey.rawValue)
        self.cacheImages = .init()
        self.cacheBuddyicons = .init()
        self.cachePostInformation = .init()
        self.ids = .init()
        self.page = 1
    }
    
    // MARK: - TEST
    private var posts: [PostDetails] = .init()
    
    func filter(by filterType: FilterType, completionHandler: @escaping () -> Void) {
        switch filterType {
        case .per50:
            perPage = 50
        case .per100:
            perPage = 100
        case .per200:
            perPage = 200
        case .per400:
            perPage = 400
        }
//        case .faves:
//            posts.sort { element, nextElement in
//                let elementViews = Int(element.views ?? "0")
//                let nextElementViews = Int(nextElement.views ?? "0")
//                return elementViews ?? 0 > nextElementViews ?? 0
//            }
//            let temp = posts.compactMap { $0.id }
//            ids = temp.uniques
//            completionHandler()
//        case .views:
//            posts.sort { element, nextElement in
//                let elementViews = Int(element.views ?? "0")
//                let nextElementViews = Int(nextElement.views ?? "0")
//                return elementViews ?? 0 > nextElementViews ?? 0
//            }
//        case .comments:
//            posts.sort { element, nextElement in
//                let elementViews = Int(element.views ?? "0")
//                let nextElementViews = Int(nextElement.views ?? "0")
//                return elementViews ?? 0 > nextElementViews ?? 0
//            }
//        }
    }
    // MARK: - END
    
    private func addUniqValues(_ array: [Photo]) {
        ids += array.compactMap { $0.id }
        ids = ids.uniques
    }
    
    func refresh() {
        page = 1
        ids.removeAll()
        cacheImages.removeAll()
        cacheBuddyicons.removeAll()
        cachePostInformation.removeAll()
    }
    
    func requestAndSetupPostIntoTable(tableView: UITableView, postCell: PostTableViewCell, indexPath: IndexPath) {
        requestPostInformation(position: indexPath.row) { [weak self] result in
            switch result {
            case .success(let postInformation):
                if postInformation.type == .network {
                    if let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                        cellForRow.configure(for: postInformation.information)
                    } //else {
                       // cell.configure(for: postInformation.information)
                    //}
                } else {
                    postCell.configure(for: postInformation.information)
                }
                
                self?.requestBuddyicon(post: postInformation.information) { [weak self] result in
                    switch result {
                    case .success(let postBuddyicon):
                        if postBuddyicon.type == .network {
                            if let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                                cellForRow.setupBuddyicon(image: postBuddyicon.image)
                            } //else {
                              //  cell.setupBuddyicon(image: postBuddyicon.image)
                            //}
                        } else {
                            postCell.setupBuddyicon(image: postBuddyicon.image)
                        }

                    case .failure(let error):
                        print("Download buddyicon error: \(error)")
                    }
                }
                
                self?.requestImage(post: postInformation.information) { [weak self] result in
                    switch result {
                    case .success(let postImage):
                        if postImage.type == .network {
                            guard let cellForRow = tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
                            cellForRow.setupPostImage(image: postImage.image)
                        } else {
                            postCell.setupPostImage(image: postImage.image)
                        }
                    case .failure(let error):
                        print("Download image error: \(error)")
                    }
                }
            case .failure(let error):
                print("\(#function) has error: \(error.localizedDescription)")
            }
        }
    }
    
    func requestPostsId(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        networkService.getRecentPosts(page: page, perPage: perPage) { [weak self] result in
            completionHandler(result.map {
                self?.page += 1
                self?.addUniqValues($0)
                return Void()
            })
        }
    }
    
    func requestPostInformation(position: Int, completionHandler: @escaping (Result<PostInformation, Error>) -> Void) {
        let cachePostInformationIdentifier = ids[position] as NSString
        if let postInformationCache = try? cachePostInformation.get(for: cachePostInformationIdentifier) {
            let postInformation = PostInformation(information: postInformationCache, type: .cache)
            completionHandler(.success(postInformation))
            return
        }
        
        networkService.getPhotoById(with: ids[position]) { [weak self] result in
            completionHandler(result.map {
                self?.posts.append($0)
                self?.cachePostInformation.set(for: $0, with: cachePostInformationIdentifier)
                let postInformation = PostInformation(information: $0, type: .network)
                return postInformation
            })
        }
    }
    
    func requestImage(post: PostDetails, completionHandler: @escaping (Result<PostImage, Error>) -> Void) {
        guard
            let id = post.id,
            let secret = post.secret,
            let server = post.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheImageIdentifier = id + secret + server as NSString
        if let imageCache = try? cacheImages.get(for: cacheImageIdentifier) {
            let postImage = PostImage(image: imageCache, type: .cache)
            completionHandler(.success(postImage))
            return
        }
        
        networkService.image(postId: id, postSecret: secret, serverId: server) { [weak self] result in
            completionHandler(result.map {
                self?.cacheImages.set(for: $0, with: cacheImageIdentifier)
                let postImage = PostImage(image: $0, type: .network)
                return postImage
            })
        }
    }
    
    func requestBuddyicon(post: PostDetails, completionHandler: @escaping (Result<PostImage, Error>) -> Void) {
        guard
            let farm = post.owner?.iconFarm,
            let server = post.owner?.iconServer,
            let nsid = post.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        let cacheBuddyiconIdentifier = String(farm) + server + nsid as NSString
        if let buddyiconCache = try? cacheBuddyicons.get(for: cacheBuddyiconIdentifier) {
            let postBuddyicon = PostImage(image: buddyiconCache, type: .cache)
            completionHandler(.success(postBuddyicon))
            return
        }
        
        networkService.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { [weak self] result in
            completionHandler(result.map {
                self?.cacheBuddyicons.set(for: $0, with: cacheBuddyiconIdentifier)
                let postBuddyicon = PostImage(image: $0, type: .network)
                return postBuddyicon
            })
        }
    }
    
}

// MARK: - Array Unique Values

extension Array where Element: Hashable {
    
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
}
