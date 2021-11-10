//
//  ImageDataManager.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import Foundation

// MARK: - Error

private enum ImageDataManagerError: Error {
    case filePathDoesNotExists
}

public class ImageDataManager {
    
    private let fileManager: FileManager
    
    private let folderPath: String
    
    init(name: String, fileManager: FileManager = FileManager.default) throws {
        self.fileManager = fileManager

        let url = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let folderPath = url.appendingPathComponent(name, isDirectory: true).path
        self.folderPath = folderPath
                
        try initDirectoryIfNeeded()
        try setDirectoryAttributes([.protectionKey: FileProtectionType.complete])
    }
    
    // MARK: - Save Methods
    
    public func saveImageData(data imageData: Data, forKey key: String) throws -> String {
        let filePath = self.makeFilePath(for: key)
        self.fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        return filePath
    }
    
    // MARK: - Fetch Methods
    
    public func fetchImageData(forKey key: String) throws -> Data {
        let filePath = self.makeFilePath(for: key)
        let url = URL(fileURLWithPath: filePath)
        let imageData = try Data(contentsOf: url)
        return imageData
    }
    
    public func fetchImageData(filePath path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        let imageData = try Data(contentsOf: url)
        return imageData
    }
    
    // MARK: - Delete Methods
    
    public func deleteImageData(filePath path: String) throws {
        if self.fileManager.fileExists(atPath: path) {
            try self.fileManager.removeItem(atPath: path)
        } else {
            throw ImageDataManagerError.filePathDoesNotExists
        }
    }
    
    public func deleteImageData(forKey key: String) throws {
        let filePath = self.makeFilePath(for: key)
        
        if self.fileManager.fileExists(atPath: filePath) {
            try self.fileManager.removeItem(atPath: filePath)
        } else {
            throw ImageDataManagerError.filePathDoesNotExists
        }
    }
    
    public func deleteAllImageData() throws {
        let url = URL(fileURLWithPath: folderPath)
        let fileURLs = try self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        for fileURL in fileURLs {
            try self.fileManager.removeItem(at: fileURL)
        }
    }
    
    public func deleteDirectory() throws {
        let url = URL(fileURLWithPath: self.folderPath)
        try self.fileManager.removeItem(at: url)
    }
    
}

// MARK: - File System Helpers

private extension ImageDataManager {

    private func setDirectoryAttributes(_ attributes: [FileAttributeKey: Any]) throws {
        try self.fileManager.setAttributes(attributes, ofItemAtPath: self.folderPath)
    }
    
    private func makeFileName(for key: String) -> String {
        let fileExtension = URL(fileURLWithPath: key).pathExtension
        return fileExtension.isEmpty ? key : "\(key).\(fileExtension)"
    }

    private func makeFilePath(for key: String) -> String {
        return "\(self.folderPath)/\(self.makeFileName(for: key))"
    }
    
    private func initDirectoryIfNeeded() throws {
        if self.fileManager.fileExists(atPath: self.folderPath) {
            return
        }
        
        try self.fileManager.createDirectory(atPath: self.folderPath, withIntermediateDirectories: true, attributes: nil)
    }
    
}
