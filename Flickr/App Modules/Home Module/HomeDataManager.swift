//
//  StorageService.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import Foundation

public struct DomainPhotoDetails: Hashable {
    
    public init(details: PhotoDetailsEntity?, imagePath: String?, buddyiconPath: String?) {
        self.details = details
        self.imagePath = imagePath
        self.buddyiconPath = buddyiconPath
    }
    
    public var details: PhotoDetailsEntity?
    public var imagePath: String?
    public var buddyiconPath: String?
}

public class HomeDataManager {
    
    private let network: Network
    
    private let coreDataManager: CoreDataManager
    
    let imageDataManager: ImageDataManager
    
    let connection: InternetConnectivity
    
    private var setOfObjects = [String: PhotoDetailsEntity]()
    
    public init(network: Network, database: CoreDataManager, connection: InternetConnectivity) {
        self.network = network
        self.coreDataManager = database
        self.connection = connection
        
        do {
            self.imageDataManager = try .init(name: "FlickrImages")
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.connection.startMonitoring()
    }
    
    // MARK: - Update Methods
    
    //    public func refreshStorage() {
    //        do {
    //            try coreDataManager.clearDatabase()
    //            try imageDataManager.deleteAllImageData()
    //            //setOfObjects.removeAll()
    //        } catch {
    //            print("Refresh failed")
    //        }
    //    }
    
    // MARK: - Request Methods
    
    func loadOfflineData(completionHandler: @escaping (Result<[DomainPhotoDetails], Error>) -> Void) {
        do {
            let domainObjects = try coreDataManager.fetchSetOfObjects()
            completionHandler(.success(domainObjects))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    public func loadOnlineData(page: Int, ids: [String], completionHandler: @escaping ([DomainPhotoDetails]) -> Void) {
        var temporaryDictionaryOfObjects = [DomainPhotoDetails]()
        
        let loadListGroup = DispatchGroup()
        //let dispatchSemaphore = DispatchSemaphore(value: ids.count)
        
        for id in ids {
            loadListGroup.enter()
            let group = DispatchGroup()
            
            self.networkRequestPhotoDetails(id: id, group: group) { [weak self] result in
                switch result {
                case .success(let details):
                    
                    
                    self?.networkGroupRequestImagesOfPhotoDetails(details: details, group: group) { imageData, buddyiconData in
                        var imagePath: String?
                        if let imageData = imageData, let secret = details.secret, let server = details.server {
                            let imageIdentifier = id + secret + server
                            imagePath = try? self?.imageDataManager.saveImageData(data: imageData, forKey: imageIdentifier)
                        }
                        
                        var buddyiconPath: String?
                        if let buddyiconData = buddyiconData, let farm = details.owner?.iconFarm, let server = details.owner?.iconServer, let nsid = details.owner?.nsid {
                            let buddyiconIdentifier = String(farm) + server + nsid
                            buddyiconPath = try? self?.imageDataManager.saveImageData(data: buddyiconData, forKey: buddyiconIdentifier)
                        }
                        
                        let domainEntity = DomainPhotoDetails(details: details, imagePath: imagePath, buddyiconPath: buddyiconPath)
                        temporaryDictionaryOfObjects.append(domainEntity)
                        //dispatchSemaphore.signal()
                        loadListGroup.leave()
                    }
                case .failure(let error):
                    //dispatchSemaphore.signal()
                    loadListGroup.leave()
                    print("Download photo details error: \(error)")
                }
                
            }
            
            //dispatchSemaphore.wait()
        }
        
        
        loadListGroup.notify(queue: .main) {
            
            
            if page == 1 {
                if let objs = try? self.coreDataManager.fetchSetOfObjects() {
                    objs.forEach {
                        if let imagePath = $0.imagePath {
                            try? self.imageDataManager.deleteImageData(filePath: imagePath)
                        }
                        
                        if let buddyiconPath = $0.buddyiconPath {
                            try? self.imageDataManager.deleteImageData(filePath: buddyiconPath)
                        }
                    }
                    
                    
                }
            }
            self.arrayOfObjects += temporaryDictionaryOfObjects
            self.arrayOfObjects = self.arrayOfObjects.uniques
            
            try? self.coreDataManager.clearDatabase()
            try? self.coreDataManager.saveSetOfObjects(objects: self.arrayOfObjects)
            
            completionHandler(temporaryDictionaryOfObjects)
        }
    }
    
    private var arrayOfObjects = [DomainPhotoDetails]()
    
    public func requestArrayPhotoDetailsIds(page: Int, per: Int, completionHandler: @escaping (Result<[String], Error>) -> Void) {
        if connection.isReachable {
            network.getRecentPosts(page: page, perPage: per) { result in
                completionHandler(result.map { array in
                    let ids = array.map {
                        $0.id!
                    }
                    return ids
                })
            }
        } else {
            do {
                let objects = try coreDataManager.fetchSetOfObjects()
                
                var ids = [String]()
                objects.forEach {
                    if let id = $0.details?.id {
                        setOfObjects[id] = $0.details!
                        ids.append(id)
                    }
                }
                
                completionHandler(.success(ids))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Request Group Helpers
    
    private func networkGroupRequestImagesOfPhotoDetails(
        details: PhotoDetailsEntity,
        group: DispatchGroup,
        completionHandler: @escaping (_ image: Data?, _ budddyicon: Data?) -> Void
    ) {
        var image: Data?
        var budddyicon: Data?
        
        networkRequestImage(details: details, group: group) { result in
            switch result {
            case .success(let imageData):
                image = imageData
            case .failure(let error):
                print("Download image error: \(error)")
            }
        }
        
        networkRequestBuddyicon(details: details, group: group) { result in
            switch result {
            case .success(let budddyiconData):
                budddyicon = budddyiconData
            case .failure(let error):
                print("Download buddyicon error: \(error)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler(image, budddyicon)
        }
    }
    
    private func networkRequestImage(
        details: PhotoDetailsEntity,
        group: DispatchGroup,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        group.enter()
        
        guard
            let id = details.id,
            let secret = details.secret,
            let server = details.server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        //        let imageIdentifier = id + secret + server
        //        if let imageData = try? imageDataManager.fetchImageData(forKey: imageIdentifier) {
        //            completionHandler(.success(imageData))
        //            group.leave()
        //            return
        //        }
        
        network.image(id: id, secret: secret, server: server) { result in
            group.leave()
            
            switch result {
            case .success(let imageData):
                completionHandler(.success(imageData))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private func networkRequestBuddyicon(
        details: PhotoDetailsEntity,
        group: DispatchGroup,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        group.enter()
        
        guard
            let farm = details.owner?.iconFarm,
            let server = details.owner?.iconServer,
            let nsid = details.owner?.nsid
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            group.leave()
            return
        }
        
        //        let buddyiconIdentifier = String(farm) + server + nsid
        //        if let buddyiconData = try? imageDataManager.fetchImageData(forKey: buddyiconIdentifier) {
        //            completionHandler(.success(buddyiconData))
        //            group.leave()
        //            return
        //        }
        
        network.buddyicon(iconFarm: farm, iconServer: server, nsid: nsid) { result in
            completionHandler(result.map {
                group.leave()
                return $0
            })
        }
    }
    
    private func networkRequestPhotoDetails(
        id: String,
        group: DispatchGroup,
        completionHandler: @escaping (Result<PhotoDetailsEntity, Error>) -> Void
    ) {
        group.enter()
        
        //        if let details = setOfObjects[id] {
        //            completionHandler(.success(details))
        //            group.leave()
        //            return
        //        }
        
        network.getPhotoById(for: id) { [weak self] result in
            completionHandler(result.map {
                //self?.setOfObjects[id] = $0
                group.leave()
                return $0
            })
        }
    }
    
    deinit {
        connection.stopMonitoring()
        print("\(type(of: self)) deinited.")
    }
    
}
