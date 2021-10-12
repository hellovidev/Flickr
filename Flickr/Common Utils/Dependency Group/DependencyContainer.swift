//
//  DependencyContainer.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 09.10.2021.
//

import UIKit

protocol DependencyContainerProtocol {
    func register<T: DependencyProtocol>(_ dependency: T)
    func retrive<T: DependencyProtocol>() throws -> T
}

//protocol DependencyContainerProtocol {
//    static func register<T: DependencyProtocol>(_ dependency: T)
//    static func retrive<T: DependencyProtocol>() throws -> T
//}

class DependencyContainer: DependencyContainerProtocol {
    
    private var dependencies: [String: Weak] = [:]
    
    func register<T: DependencyProtocol>(_ dependency: T) {
        let key: String = "\(type(of: T.self))"
        let weak: Weak = .init(value: dependency as AnyObject)
        dependencies[key] = weak
    }
    
    func retrive<T: DependencyProtocol>() throws -> T {
        let key: String = "\(type(of: T.self))"
        let weak = dependencies[key]
        
        //precondition(weak == nil, "No dependency found for key - [\(key)], application must register a dependency before retriving it.")
        
        guard let dependency = weak?.value as? T else { throw DependencyContainerError.nilDependency }
                
        //precondition(weak?.value as? T == nil, "No dependency found for key - [\(key)], dependency is already deallocated by the system.")
        
        return dependency
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

//class DependencyContainer: DependencyContainerProtocol {
//
//    private static let shared: DependencyContainer = .init()
//
//    private var dependencies: [String: Weak] = [:]
//
//    private init() {}
//
//    static func register<T: DependencyProtocol>(_ dependency: T) {
//        shared.register(dependency)
//    }
//
//    static func retrive<T: DependencyProtocol>() throws -> T {
//        try shared.retrive()
//    }
//
//    private func register<T: DependencyProtocol>(_ dependency: T) {
//        let key: String = "\(type(of: T.self))"
//        let weak: Weak = .init(value: dependency as AnyObject)
//        dependencies[key] = weak
//    }
//
//    private func retrive<T: DependencyProtocol>() throws -> T {
//        let key: String = "\(type(of: T.self))"
//        let weak = dependencies[key]
//
//        //precondition(weak == nil, "No dependency found for key - [\(key)], application must register a dependency before retriving it.")
//
//        guard let dependency = weak?.value as? T else { throw DependencyContainerError.nilDependency }
//
//        //precondition(weak?.value as? T == nil, "No dependency found for key - [\(key)], dependency is already deallocated by the system.")
//
//        return dependency
//    }
//
//    static func clear() {
//        shared.clear()
//    }
//
//    private func clear() {
//        dependencies.removeAll()
//    }
//
//    deinit {
//        print("\(type(of: self)) deinited.")
//    }
//
//}

enum DependencyContainerError: Error {
    case nilDependency
}

class Weak: Equatable {
    
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
    
    static func == (lhs: Weak, rhs: Weak) -> Bool {
        return lhs.value === rhs.value
    }
    
}

protocol DependencyProtocol: AnyObject {}

//@propertyWrapper
//class Dependency<T: DependencyProtocol> {
//    
//    var wrappedValue: T {
//        try! DependencyContainer.retrive()
//    }
//    
//    
//    
//}
