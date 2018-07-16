//
//  Amatino Swift
//  UrlParameters.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

internal struct UrlParameters: CustomStringConvertible {
    
    let targets: [UrlTarget]
    let paramString: String
    let entity: Entity?
    var description: String {
        return paramString
    }
    
    init(singleEntity entity: Entity) {
        self.entity = entity
        paramString = "?entity_id=" + entity.id
        targets = [UrlTarget]()
        return
    }
    
    init(entityWithTargets entity: Entity, targets: [UrlTarget]) {
        self.entity = entity
        self.targets = targets
        var workingString = "?entity_id=" + entity.id
        for target in targets {
            workingString += "&" + String(describing: target)
        }
        paramString = workingString
        return
    }

    init(targetsOnly: [UrlTarget]) {
        
        entity = nil
        
        if targetsOnly.count < 1 {
            paramString = ""
            targets = [UrlTarget]()
            return
        }
        
        targets = targetsOnly
        var workingString = "?" + String(describing: targets[0])
        for target in targets.dropFirst() {
            workingString += "&" + String(describing: target)
        }
        paramString = workingString
        return
    }

    init(fromRawQuery query: String) {
        self.entity = nil
        paramString = query
        targets = [UrlTarget]()
        return
    }

    /* Removed pending re-write of Entity class
    static func merge(
        parameters: [UrlParameters],
        entity: Entity
    ) throws -> UrlParameters {
        var workingArray = Array<UrlTarget>()
        for parameter in parameters {
            if parameter.entity == nil {
                throw InternalLibraryError(.InconsistentState)
            }
            guard parameter.entity! == entity else {
                throw InternalLibraryError(.InconsistentState)
            }
            workingArray += parameter.targets
        }
        let targetSet = Set(workingArray)
        let uniqueArray = Array<UrlTarget>(targetSet)
        return try UrlParameters(
            entityWithTargets: entity,
            targets: uniqueArray
        )
    }
    */
}
