//
//  FlickrImageDataManagerTests.swift
//  FlickrTests
//
//  Created by Siarhei Ramanchuk on 11/11/21.
//

import XCTest
import Flickr

class FlickrImageDataManagerTests: XCTestCase {

    let container: SystemUnderTestContainer = .init()
    
    func test_save_imageData() {
        let sut = container.imageDataManager
        let key: String = "GDFK-63HJU"
        if let imageData = UIImage(named: "FlickrLogotype")?.pngData() {
            do {
                let path = try sut.saveImageData(data: imageData, forKey: key)
                XCTAssertNotNil(path)
            } catch {
                XCTFail("Save image data error: \(error)")
            }
        }
    }
    
    func test_fetch_imageDataByKey() {
        let sut = container.imageDataManager
        let key: String = "GDFK-63HJU"
        
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            do {
                let imageData = try sut.fetchImageData(forKey: key)
                XCTAssertNotNil(imageData)
            } catch {
                XCTFail("Fetch image data error: \(error)")
            }
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_delete_imageDataByKey() {
        let sut = container.imageDataManager
        let key: String = "GDFK-63HJU"
        
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertNoThrow(try sut.deleteImageData(forKey: key))
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_delete_imageDataAll() {
        let sut = container.imageDataManager
        
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertNoThrow(try sut.deleteAllImageData())
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_delete_directory() {
        let sut = container.imageDataManager
        
        let exp = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertNoThrow(try sut.deleteDirectory())
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    // MARK: - Helpers
    
    class SystemUnderTestContainer {
        
        let imageDataManager: ImageDataManager
        
        init() {
            imageDataManager = try! .init(name: "TestFolder")
        }
        
    }

}
