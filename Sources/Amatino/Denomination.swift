//
//  Denomination.swift
//  Amatino
//
//  Created by Hugh Jeremy on 1/4/19.
//

import Foundation

public protocol Denomination {
    
    var code: String { get }
    var id: Int { get }
    var name: String { get }
    var priority: Int { get }
    var description: String { get }
    var exponent: Int { get }

}
