//
//  PermissionsGraph.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

internal struct PermissionsGraph: Codable {
    
    internal let rawGraph: [String:[String:[String:Bool]]]
    
    enum CodingKeys: String, CodingKey {
        case rawGraph = "permissions_graph"
    }
    
}
