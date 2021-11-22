//
//  GalleryViewModel.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 25.09.2021.
//

import UIKit

// MARK: - GalleryViewModel

class GalleryViewModel {
    
    // MARK: - Variables
    
    private var dataProvider: GalleryDataProvider
    private weak var coordinator: GeneralCoordinator?
    
    public init(coordinator: GeneralCoordinator, userId: String, network: Network, contextProvider: CoreDataContextProvider) {
        self.coordinator = coordinator
        
        do {
            let fileManager = try FileManagerAPI(name: "UserImages")
            let database = UserPhotoCoreData(context: contextProvider.viewContext)
            dataProvider = .init(userId: userId, network: network, database: database, fileManager: fileManager)
        } catch {
            fatalError("Unresolved error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    public var numberOfItems: Int {
        dataProvider.numberOfElements + 1
    }
    
    // MARK: - Element Controler
    
    public enum DataSourceItem {
        case uploadPhoto
        case galleryPhoto(index: Int)
    }
    
    public func itemAt(indexPath: IndexPath) -> DataSourceItem {
        if indexPath.row == 0 {
            return .uploadPhoto
        }
        
        return .galleryPhoto(index: indexPath.row - 1)
    }
    
    // MARK: - Refresh Methods
    
    public func refreshGallery(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.fetch(completionHandler: completionHandler)
    }
    
    // MARK: - Upload Methods
    
    public func uploadUserPhoto(data: Data, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.save(data: data, completionHandler: completionHandler)
    }
    
    // MARK: - Retrive Methods
    
    public func initialRetriveUserPhotos(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.fetch(completionHandler: completionHandler)
    }
    
    public func retriveUserPhoto(index: Int, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        dataProvider.fetchImage(index: index) { result in
            completionHandler(result.map {
                return UIImage(data: $0)!
            })
        }
    }
    
    // MARK: - Delete Methods
    
    public func deleteUserPhoto(index: Int, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.detele(index: index, completionHandler: completionHandler)
    }
    
    // MARK: - Deinit
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}
