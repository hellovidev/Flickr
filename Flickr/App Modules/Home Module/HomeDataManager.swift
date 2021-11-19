//
//  StorageService.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import Foundation

public class HomeDataManager {
    
    private let network: Network
    
    let coreDataManager: CoreDataManager
    
    let imageDataManager: ImageDataManager
    
    public init(network: Network, database: CoreDataManager) {
        self.network = network
        self.coreDataManager = database
        
        do {
            self.imageDataManager = try .init(name: "FlickrImages")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - General Requests
    
    private var currentObjects = [PhotoDetailsEntity]()
    
    func requestEntityIds(page: Int, per: Int, completionHandler: @escaping (Result<[String], Error>) -> Void) {
        network.getRecentPosts(page: page, perPage: per) { result in
            completionHandler(result.map { array in
                var ids = [String]()
                for element in array {
                    if let id = element.id {
                        ids.append(id)
                    }
                }
                return ids
            })
        }
    }
    
    public func loadOnlineData(page: Int, pageIds: [String], completionHandler: @escaping (Result<[PhotoDetailsEntity], Error>) -> Void) {
        let group = DispatchGroup()
        var temporaryObjects = [PhotoDetailsEntity]()
        
        for id in pageIds {
            group.enter()
            requestPhotoDetails(id: id) { result in
                switch result {
                case .success(let details):
                    temporaryObjects.append(details)
                case .failure(let error):
                    print("Download details error: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if page == 1 {
                self.currentObjects.removeAll()
                if let databaseObjects = try? self.coreDataManager.fetchObjects(){//fetchSetOfObjects() {
                    try? self.deleteImagesOfObjects(databaseObjects)
                }
            }
            
            self.currentObjects += temporaryObjects
            try? self.coreDataManager.clearDatabase()
            try? self.coreDataManager.saveSetOfObjects(objects: self.currentObjects)
            completionHandler(.success(self.currentObjects))
        }
    }
    
    func loadOfflineData(completionHandler: @escaping (Result<[PhotoDetailsEntity], Error>) -> Void) {
        do {
            let domainObjects = try coreDataManager.fetchObjects()//fetchSetOfObjects()
            self.currentObjects = domainObjects
            completionHandler(.success(self.currentObjects))
        } catch {
            completionHandler(.failure(error))
        }
    }
        
    // MARK: - Parts of Photo Request
    
    func requestPhotoDetails(id: String, completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void) {
        network.getPhotoById(for: id, completionHandler: completionHandler)
    }
    
    func requestImage(id: String, secret: String, server: String, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        network.image(id: id, secret: secret, server: server, completionHandler: { [weak self] result in
            completionHandler(result.map {
                let imageIdentifier = id + secret + server
                _ = try? self?.imageDataManager.saveImageData(data: $0, forKey: imageIdentifier)
                return $0
            })
        })
    }
    
    func requestBuddyicon(farm: Int, server: String, nsid: String, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid, completionHandler: { [weak self] result in
            completionHandler(result.map {
                let buddyiconIdentifier = String(farm) + server + nsid
                _ = try? self?.imageDataManager.saveImageData(data: $0, forKey: buddyiconIdentifier)
                return $0
            })
        })
    }
    
    // MARK: - Helpers
    
    func deleteImagesOfObjects(_ objects: [PhotoDetailsEntity]) throws {
        for object in objects {
            guard
                let id = object.id,
                let secret = object.secret,
                let serverImage = object.server
            else {
                throw NetworkManagerError.invalidParameters
            }
            
            guard
                let farm = object.owner?.iconFarm,
                let serverBuddyicon = object.owner?.iconServer,
                let nsid = object.owner?.nsid
            else {
                throw NetworkManagerError.invalidParameters
            }
            
            let imageIdentifier = id + secret + serverImage
            let buddyiconIdentifier = String(farm) + serverBuddyicon + nsid
            
            try self.imageDataManager.deleteImageData(forKey: imageIdentifier)
            try self.imageDataManager.deleteImageData(forKey: buddyiconIdentifier)
        }
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
