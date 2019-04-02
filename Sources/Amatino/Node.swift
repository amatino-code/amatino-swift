//
//  Node.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public protocol Node: AccountRepresentative {

    var accountId: Int { get }
    var name: String { get }
    var type: AccountType { get }
    var depth: Int { get }
    var children: Array<Node> { get }
    var flatChildren: Array<Node> { get }

}

extension Node {
    
    public var flatChildren: Array<Node> {
        get {
            let recursedChildren = self.children.map { $0.flatChildren }
            let flatRecursion = recursedChildren.reduce(
                Array<Node>(),
                { x, y in x + y}
            )
            return flatRecursion
        }
    }

}
