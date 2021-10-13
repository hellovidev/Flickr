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
    func addObserver(_ observer: Observer)
}

final class Observable<T>: ObservableProtocol {
    
    typealias ValueType = T

    var observers: [(T) -> Void] = []
    
    func send(_ value: T) {
        observers.forEach { $0(value) }
    }
    
    func addObserver(_ observer: @escaping (T) -> Void) {
        observers.append(observer)
    }
    
}
