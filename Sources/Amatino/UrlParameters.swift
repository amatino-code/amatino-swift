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
    let entity: Entity
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
    
    static func merge(parameters: [UrlParameters], entity: Entity) throws -> UrlParameters{
        var workingArray = Array<UrlTarget>()
        for parameter in parameters {
            guard parameter.entity == entity else {throw InternalLibraryError.InconsistentState()}
            workingArray += parameter.targets
        }
        let targetSet = Set(workingArray)
        let uniqueArray = Array<UrlTarget>(targetSet)
        return UrlParameters(entityWithTargets: entity, targets: uniqueArray)
    }
}
