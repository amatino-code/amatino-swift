//
//  AccountSummary.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public class TreeNode: Node, Decodable {

    public let id: Int
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
        id = try container.decode(Int.self, forKey: .accountId)
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
            container: container, key: .children
        )
        return
    }
    
    internal static func decodeNodes<K: CodingKey>(
        container: KeyedDecodingContainer<K>,
        key: K
        ) throws -> Array<Node> {
        guard container.contains(key) else {
            throw AmatinoError(.badResponse)
        }
        var childrenContainer: UnkeyedDecodingContainer
        /* the value for key may be nil. We don't have a clean way to get either
           an UnkeyedDecodingContainer or nil, so we have to control flow with
           a do-catch block.
        */
        do {
            childrenContainer = try container.nestedUnkeyedContainer(forKey: key)
        } catch {
            /* Int? stands in as a dummy type. We expect nil, never an Int. If
               we do in fact find nil, we can be confident no error has occured
               and we may safely return an empty Node array.
            */
            let sample = try container.decode(Int?.self, forKey: key)
            guard sample == nil else {
                throw error
            }
            return Array<Node>()
        }
        var childrenContainerToDecode = childrenContainer
        var childNodes = [Node]()
        while(!childrenContainer.isAtEnd) {
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
