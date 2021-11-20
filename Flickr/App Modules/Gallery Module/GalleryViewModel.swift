//
//  GalleryViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - GalleryViewModel

class GalleryViewModel {
    
    // MARK: - TEST
    
    private lazy var dataProvider: GalleryDataProvider = .init(userId: nsid, network: network, database: database, fileManager: fileManager)
    private var fileManager: FileManagerAPI
    @UserDefaultsBacked(key: UserDefaults.Keys.nsid.rawValue)
    private var nsid: String!
    private var database: UserPhotoCoreData
    private var network: Network
    
    // ------
    
    private weak var coordinator: GeneralCoordinator?
    
    //private let repository: GalleryRepository
    
    init(coordinator: GeneralCoordinator, network: Network, contextProvider: CoreDataContextProvider) {
        self.coordinator = coordinator
        //self.repository = .init(network: network)
        
        
        self.network = network

        database = .init(context: contextProvider.viewContext)
        
        do {
            self.fileManager = try .init(name: "UserImages")
        } catch {
            fatalError(error.localizedDescription)
        }
        
        //dataProvider = .init(userId: nsid, network: network, database: database, fileManager: fileManager)
        
        dataProvider.loadDataNeedUpdate = {
            self.needUpdate?()
        }
    }
    
    var numberOfItems: Int {
        //repository.gallaryCount + 1
        dataProvider.numberOfElements + 1
    }
    
    enum DataSourceItem {
        case uploadPhoto
        case galleryPhoto(index: Int)
    }
    
    func itemAt(indexPath: IndexPath) -> DataSourceItem {
        if indexPath.row == 0 {
            return .uploadPhoto
        }
        return .galleryPhoto(index: indexPath.row - 1)
    }
    
    func refresh() {
        //repository.refresh()
    }
    
    func initialPhotosLoading(completionHandler: @escaping (Result<Void, Error>) -> Void) {
    }
    
    func uploadLibraryPhoto(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        //repository.uploadPhoto(data: data, completionHandler: completionHandler) // not only local saver
        dataProvider.save(data: data, completionHandler: completionHandler)
    }
    
    func removePhotoAt(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        //repository.removePhotoAt(index: index, completionHandler: completionHandler)
        dataProvider.detele(index: index, completionHandler: completionHandler)
    }
    
    func initialFetchPhotos(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        
        dataProvider.fetch(completionHandler: completionHandler)
        /*repository.fetchUserPhotoArray { [weak self] result in
            switch result {
            case .success():
                self?.repository.requestServerUserPhotoArray(completionHandler: completionHandler)
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }*/
    }
    
    var needUpdate: (() -> ())?
    
    func requestPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        //repository.requestUserPhoto(index: index, completionHandler: completionHandler)
        dataProvider.fetchImage(index: index, completionHandler: { result in
            completionHandler(result.map {
                return UIImage(data: $0)!
            })
        })
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
