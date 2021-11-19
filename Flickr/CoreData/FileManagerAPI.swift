//
//  FileManagerAPI.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/9/21.
//

import Foundation

// MARK: - Error

private enum FileManagerAPIError: Error {
    case fileDoesNotExists
    case filePathDoesNotExists
    case fileKeyDoesNotExists
}

// MARK: - General Class `FileManagerAPI`

public class FileManagerAPI {
    
    private let fileManager: FileManager
    private let folderPath: String
    
    public init(name: String, fileManager: FileManager = FileManager.default) throws {
        self.fileManager = fileManager

        let url = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let folderPath = url.appendingPathComponent(name, isDirectory: true).path
        self.folderPath = folderPath
        print(folderPath)

        try initDirectoryIfNeeded()
        try setDirectoryAttributes([.protectionKey: FileProtectionType.complete])
    }
    
    // MARK: - Save Methods
    
    public func save(fileData data: Data, forKey key: String) throws -> String {
        let filePath = self.makeFilePath(for: key)
        self.fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        return filePath
    }
    
    public func save(fileData data: Data, forKey key: String) throws {
        let filePath = self.makeFilePath(for: key)
        self.fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    // MARK: - Fetch Methods
    
    public func fetch(filePath path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        let fileData = try Data(contentsOf: url)
        return fileData
    }
    
    public func fetch(forKey key: String) throws -> Data {
        let filePath = self.makeFilePath(for: key)
        let url = URL(fileURLWithPath: filePath)
        let fileData = try Data(contentsOf: url)
        return fileData
    }
    
    // MARK: - Delete Methods
    
    public func delete(filePath path: String) throws {
        if self.fileManager.fileExists(atPath: path) {
            try self.fileManager.removeItem(atPath: path)
        } else {
            throw FileManagerAPIError.filePathDoesNotExists
        }
    }
    
    public func delete(forKey key: String) throws {
        let filePath = self.makeFilePath(for: key)
        
        if self.fileManager.fileExists(atPath: filePath) {
            try self.fileManager.removeItem(atPath: filePath)
        } else {
            throw FileManagerAPIError.fileKeyDoesNotExists
        }
    }
    
    public func deleteAllFiles() throws {
        let url = URL(fileURLWithPath: folderPath)
        let fileURLs = try self.fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        for fileURL in fileURLs {
            try self.fileManager.removeItem(at: fileURL)
        }
    }
    
    public func deleteFolder() throws {
        let url = URL(fileURLWithPath: self.folderPath)
        try self.fileManager.removeItem(at: url)
    }
    
    // MARK: - Rename Methods
    
    public func rename(atKey: String, toKey: String) throws {
        let fileAtPath = self.makeFilePath(for: atKey)
        let fileToPath = self.makeFilePath(for: toKey)
        
        try self.fileManager.moveItem(atPath: fileAtPath, toPath: fileToPath)
    }
    
}

// MARK: - File System Helpers

private extension FileManagerAPI {

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
