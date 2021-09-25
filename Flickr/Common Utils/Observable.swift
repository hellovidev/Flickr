//
//  Observable.swift
//  Flickr
//
//  Created by Sergei Romanchuk on 23.09.2021.
//

import Foundation

protocol ObservableProtocol {
    associatedtype ValueType
    associatedtype Observer = (ValueType) -> Void
    var observers: [Observer] { get set }
    var value: ValueType { get set }
    func addObserver(_ observer: Observer)
}

final class Observable<T>: ObservableProtocol {
    
    typealias ValueType = T

    var observers: [(T) -> Void] = []

    var value: T {
        didSet {
            observers.forEach { $0(value) }
        }
    }
    
//    func send(_ value: T) {
//        observers.forEach { $0(value) }
//    }
    
    init(_ defaultValue: T) {
        value = defaultValue
    }
    
    func addObserver(_ observer: @escaping (T) -> Void) {
        observers.append(observer)
    }
    
}
