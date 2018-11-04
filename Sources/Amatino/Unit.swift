//
//  Unit.swift
//  Amatino
//
//  Created by Hugh Jeremy on 7/8/18.
//

import Foundation

public protocol Unit {
    
    var code: String { get }
    var id: Int { get }
    var name: String { get }
    var priority: Int { get }
    var description: String { get }
    var exponent: Int { get }
    
}

