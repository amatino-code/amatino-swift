//
//  Amatino Swift
//  UrkParameters.swift
//
//  Created by Hugh Jeremy on 1/2/18.
//

import Foundation

internal class UrlParameters {
    
    let paramString: String
    
    init(singleEntity entity: Entity) {
        self.paramString = "?entity_id=" + entity.id
        return
    }
}
