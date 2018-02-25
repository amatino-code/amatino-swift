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
    var entity: Entity? = nil
    var description: String {
        return paramString
    }
    
    init(singleEntity entity: Entity) throws {
        self.entity = entity
        paramString = try "?entity_id=" + entity.id()
        targets = [UrlTarget]()
        return
    }
    
    init(entityWithTargets entity: Entity, targets: [UrlTarget]) throws {
        self.entity = entity
        self.targets = targets
        var workingString = try "?entity_id=" + entity.id()
        for target in targets {
            workingString += "&" + String(describing: target)
        }
        paramString = workingString
        return
    }

    init(targetsOnly: [UrlTarget]) {
        
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
    
    static func merge(parameters: [UrlParameters], entity: Entity) throws -> UrlParameters{
        
        var workingArray = Array<UrlTarget>()
        for parameter in parameters {
            guard parameter.entity != nil else {throw InternalLibraryError(.InconsistentState)}
            let existingEntityId = try parameter.entity!.id()
            let newEntityId = try entity.describe().entityId
            guard existingEntityId == newEntityId else {throw InternalLibraryError(.InconsistentState)}
            workingArray += parameter.targets
        }
        let targetSet = Set(workingArray)
        let uniqueArray = Array<UrlTarget>(targetSet)
        return try UrlParameters(entityWithTargets: entity, targets: uniqueArray)
    }
}
