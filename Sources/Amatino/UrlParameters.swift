//
//  Amatino Swift
//  UrlParameters.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

internal struct UrlParameters: CustomStringConvertible {
    
    let paramString: String
    var description: String {
        return paramString
    }
    
    init(singleEntity entity: Entity) {
        paramString = "?entity_id=" + entity.id
        return
    }
    
    init(entityWithTargets entity: Entity, targets: [UrlTarget]) {
        var workingString = "?entity_id=" + entity.id
        for target in targets {
            workingString += "&" + String(describing: target)
        }
        paramString = workingString
        return
    }
}
