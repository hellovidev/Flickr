//
//  NSManagedObject+DatabaseEntityProtocol.swift
//  Flickr
//
//  Created by Siarhei Ramanchuk on 11/7/21.
//

import Foundation
import CoreData

/**
 All Core Data entities inherit the `NSManagedObject`, and by default, `NSManagedObject` does not implement the `DatabaseEntityProtocol` protocol. To mark the `NSManagedObject` as storable we need to conform it to the `DatabaseEntityProtocol`.
 */

extension NSManagedObject: DatabaseEntityProtocol { }
