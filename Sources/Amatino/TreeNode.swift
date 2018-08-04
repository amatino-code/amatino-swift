//
//  AccountSummary.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public class TreeNode: Node, Decodable {

    public let accountId: Int
    public let name: String
    public let type: AccountType
    public let depth: Int
    public let balance: Decimal
    public let presentationBalance: String
    public let recursiveBalance: Decimal
    public let presentationRecursiveBalance: String
    public let children: Array<Node>
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONObjectKeys.self)
        accountId = try container.decode(Int.self, forKey: .accountId)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(AccountType.self, forKey: .type)
        depth = try container.decode(Int.self, forKey: .depth)
        presentationBalance = try container.decode(
            String.self,
            forKey: .balance
        )
        let magnitude = try Magnitude(fromString: presentationBalance)
        balance = magnitude.decimal
        presentationRecursiveBalance = try container.decode(
            String.self,
            forKey: .recursiveBalance
        )
        let recursiveMagnitude = try Magnitude(
            fromString: presentationRecursiveBalance
        )
        recursiveBalance = recursiveMagnitude.decimal
        children = try TreeNode.decodeNodes(
            container: container.nestedUnkeyedContainer(forKey: .children)
        )
        return
    }
    
    internal static func decodeNodes(
        container: UnkeyedDecodingContainer
        ) throws -> Array<Node> {
        var childrenContainer = container
        var childrenContainerToDecode = container
        var childNodes = [Node]()
        while(!container.isAtEnd) {
            let childNode = try childrenContainer.nestedContainer(
                keyedBy: JSONObjectKeys.self
            )
            let testBalance = try childNode.decode(
                String?.self,
                forKey: .balance
            )
            if testBalance == nil {
                let placeholderNode = try childrenContainerToDecode.decode(
                    PlaceholderNode.self
                )
                childNodes.append(placeholderNode)
            } else {
                let treeNode = try childrenContainerToDecode.decode(
                    TreeNode.self
                )
                childNodes.append(treeNode)
            }
        }
        return childNodes
    }
    
    internal enum JSONObjectKeys: String, CodingKey {
        case accountId = "account_id"
        case name
        case type
        case depth
        case balance = "account_balance"
        case recursiveBalance = "recursive_balance"
        case children
    }
    
}
