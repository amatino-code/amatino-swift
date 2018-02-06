//
//  Amatino Swift
//  Batch.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

enum BatchError: Error {
    case InconsistentObjectType
    case InconsistentAction
    case ExceededMaxCount
    case InactiveObject
}

public class Batch {
    
    public let maxCount = 10
    public var count: Int {
        return objects.count
    }

    private var objects = [AmatinoObject]()
    private let objectType: Any
    private let readyCallback: (_ object: [AmatinoObject]) -> Void

    init<T: AmatinoObject>(objectType: T.Type, readyCallback: @escaping (_ object: [AmatinoObject]) -> Void) {
        self.objectType = T.self
        self.readyCallback = readyCallback
        return
    }

    internal func append(_ object: AmatinoObject) throws {
        if (objects.isEmpty) {
            guard object.currentAction != nil else {
                throw BatchError.InactiveObject
            }
            objects.append(object)
            return
        }
        guard objects.count <= maxCount else {
            throw BatchError.ExceededMaxCount
        }
        let existing = self.objects[0]
        guard object_getClassName(existing) == object_getClassName(object) else {
            throw BatchError.InconsistentObjectType
        }
        guard existing.currentAction == object.currentAction else {
            throw BatchError.InconsistentAction
        }
        objects.append(object)
        return
    }

    public func execute() {
        
        return
    }
}


