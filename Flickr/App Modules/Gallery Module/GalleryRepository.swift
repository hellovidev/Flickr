//
//  GalleryRepository.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 03.10.2021.
//

import UIKit

// MARK: - GalleryRepository

class GalleryRepository {
    
    private var network: Network

    @UserDefaultsBacked(key: UserDefaults.Keys.nsid.rawValue)
    private var nsid: String!
    
    private let localStorage: CoreDataUserPhoto<UserPhotoCoreEntity>
    
    private let imageDataManager: FileManagerAPI
    
    private var gallery = [PhotoEntity]()
        
    init(network: Network) {
        self.network = network
        
        guard let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { fatalError() }

        self.localStorage = .init(context: scene.persistentContainer.viewContext)
        
        do {
            self.imageDataManager = try .init(name: "UserImages")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    var gallaryCount: Int {
        gallery.count
    }
    
    func refresh() {
        //cacheImages.removeAll()
    }

    

    func refresh(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.fetchUserPhotoArray(completionHandler: completionHandler)
    }
    
    
    
    func requestServerUserPhotoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        network.getUserPhotos(for: nsid) { result in
            switch result {
            case .success(let onlinePhotos):
                let uniqs = self.uniqObjects(self.gallery, onlinePhotos)
                
                if uniqs.isEmpty {
                    if self.gallery.isEmpty {
                        self.gallery = onlinePhotos
                        var index = 0
                        for photo in onlinePhotos {
                            let object = UserPhotoCoreEntity(context: self.localStorage.context)
                            object.position = Int32(index)
                            object.id = photo.id
                            object.server = photo.server
                            object.secret = photo.secret
                            object.farm = Int32(photo.farm!)
                            index += 1
                        }
                    } else {
                        let enities = try! self.localStorage.fetchAll()
                        var index = 0
                        for entity in enities {
                            entity.position = Int32(index)
                            entity.id = onlinePhotos[index].id
                            entity.server = onlinePhotos[index].server
                            entity.secret = onlinePhotos[index].secret
                            entity.farm = Int32(onlinePhotos[index].farm!)
                            index += 1
                        }
                    }

                    try? self.localStorage.save()
                } else {
                    self.uploadNewOfflinePhotosToServer(uniqs) { result in
                        self.gallery = onlinePhotos
                    }
                }
                
                completionHandler(.success(()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    

    private func uniqObjects(_ whereArray: [PhotoEntity], _ compareArray: [PhotoEntity]) -> [PhotoEntity] {
        var uniqs = [PhotoEntity]()
        
        var uniq: Bool = true
        for element in whereArray {
            uniq = true
            for photo in compareArray {
                if element.id == photo.id {
                    uniq = false
                    break
                }
            }
            
            if uniq {
                uniqs.append(element)
            }
        }
    
        return uniqs
    }
    

    
    // MARK: - Methods
    
    func fetchUserPhotoArray(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let photos = try localStorage.fetchAll()
            var offlineGallery = [PhotoEntity]()
            for photo in photos {
                let entity = PhotoEntity(id: photo.id, secret: photo.secret, server: photo.server, farm: Int(photo.farm))
                offlineGallery.append(entity)
            }
            gallery = offlineGallery
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func requestUserPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard
            let id = gallery[index].id
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        if let imageData = try? imageDataManager.fetch(forKey: id) {
            let image = UIImage(data: imageData)!
            completionHandler(.success(image))
            return
        }
        
        guard
            let secret = gallery[index].secret,
            let server = gallery[index].server
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        network.image(id: id, secret: secret, server: server) { result in
            completionHandler(result.map { [weak self] in
                let image = UIImage(data: $0)!
                _ = try? self?.imageDataManager.save(fileData: $0, forKey: id)
                return image
            })
        }
    }
    private var position: Int = -1
    func uploadPhoto(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        do {
            let id = UUID().uuidString
            
            let object = UserPhotoCoreEntity(context: self.localStorage.context)

            
//            localStorage.didChange = { [weak self] in
//
//            }
            
            object.id = id
            object.position = Int32(position)
            position -= 1
            _ = try imageDataManager.save(fileData: data, forKey: id)
            try localStorage.save()
            
            let entity = PhotoEntity(id: object.id, secret: object.secret, server: object.server, farm: Int(object.farm))
            self.gallery.insert(entity, at: 0)
            DispatchQueue.main.async {
                completionHandler(.success(()))
            }
            
            self.uploadNewOfflinePhotosToServer([entity]) {result in}//, completionHandler: completionHandler)
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func uploadPhotoToServer(
        data: Data,
        title: String = "Image",
        description: String = "This image uploaded from iOS application.",
        completionHandler: @escaping (Result<String, Error>) -> Void
    ) {
        network.uploadImage(data, title: title, description: description, completionHandler: completionHandler)
    }
    
    func uploadNewOfflinePhotosToServer(_ array: [PhotoEntity], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        for element in array {
            guard let elementId = element.id else { continue }
            do {
                let imageData = try imageDataManager.fetch(forKey: elementId)
                uploadPhotoToServer(data: imageData) { [weak self] result in
                    switch result {
                    case .success(let uploadElementId):
                        do {
                            if let photo = try self?.localStorage.fetchById(elementId), let imageData = try self?.imageDataManager.fetch(forKey: elementId), let _ = try self?.imageDataManager.delete(forKey: elementId) {
                                
                                self?.gallery[0].id = uploadElementId
                                photo.id = uploadElementId
                                
                                self?.network.getPhotoById(for: uploadElementId) { result in
                                    switch result {
                                        
                                    case .success(let details):
                                        photo.server = details.server
                                        photo.farm = Int32(details.farm!)
                                        photo.secret = details.secret
                                        
                                        self?.gallery[0].server = details.server
                                        self?.gallery[0].farm = details.farm
                                        self?.gallery[0].secret = details.secret
                                        
                                        try? self?.localStorage.save()
                                        completionHandler(.success(()))
                                    case .failure(let error):
                                        
                                        print(error)
                                    }
                                }
                                _ = try self?.imageDataManager.save(fileData: imageData, forKey: uploadElementId)
                                try self?.localStorage.save()
                                
                                let objects = try! self!.localStorage.fetchAll()
                                var newIndex = 0
                                for obj in objects {
                                    obj.position = Int32(newIndex)
                                    newIndex += 1
                                }
                                try self?.localStorage.save()
                            }
                        } catch {
                            print(error)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } catch {
                completionHandler(.failure(error))
                print(error)
            }
        }
    }
    
    func removePhotoAt(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard
            let id = gallery[index].id
        else {
            completionHandler(.failure(NetworkManagerError.invalidParameters))
            return
        }
        
        network.deletePhotoById(id) { [weak self] result in
            switch result {
            case .success:
                self?.gallery.remove(at: index)
                try? self?.imageDataManager.delete(forKey: id)
                try? self?.localStorage.delete(id)
                completionHandler(.success(Void()))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    // MARK: - Database Methods
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
