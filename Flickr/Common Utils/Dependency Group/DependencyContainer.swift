//
//  DependencyContainer.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 09.10.2021.
//

import Foundation

// MARK: - Dependency Error

enum DependencyContainerError: Error {
    case nilDependency
}

// MARK: - Dependency Protocols

protocol DependencyProtocol: AnyObject {}

protocol DependencyContainerProtocol {
    func register<T: DependencyProtocol>(_ dependency: T)
    func retrive<T: DependencyProtocol>() -> T
}

// MARK: - DependencyContainer

class DependencyContainer: DependencyContainerProtocol {
    
    private var dependencies: [String: Weak] = [:]
    
    func register<T: DependencyProtocol>(_ dependency: T) {
        let key: String = "\(type(of: T.self))"
        let weak: Weak = .init(value: dependency as AnyObject)
        dependencies[key] = weak
        print(dependencies)
        print(key)
        print(weak)
    }
    
    func retrive<T: DependencyProtocol>() -> T {
        let key: String = "\(type(of: T.self))"
        let weak = dependencies[key]
        
        //precondition(weak != nil, "No dependency found for key - [\(key)], application must register a dependency before retriving it.")
        
        let dependency = weak?.value
        
        //precondition(weak?.value != nil, "No dependency found for key - [\(key)], dependency is already deallocated by the system.")
        
        return dependency as! T
    }
    
    deinit {
        print("\(type(of: self)) deinited.")
    }
    
}

// MARK: - Weak

class Weak: Equatable {
    
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
    
    static func == (lhs: Weak, rhs: Weak) -> Bool {
        return lhs.value === rhs.value
    }
    
}
