//
//  Node.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public protocol Node {
    var accountId: Int { get }
    var name: String { get }
    var type: AccountType { get }
    var depth: Int { get }
    var children: Array<Node> { get }
}
