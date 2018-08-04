//
//  PlaceholderNode.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public class PlaceholderNode: Node, Decodable {
    
    public let accountId: Int
    public let name: String
    public let type: AccountType
    public let depth: Int
    public let children: Array<Node>
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: TreeNode.JSONObjectKeys.self
        )
        accountId = try container.decode(Int.self, forKey: .accountId)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(AccountType.self, forKey: .type)
        depth = try container.decode(Int.self, forKey: .depth)
        children = try TreeNode.decodeChildren(container: container)
        return
    }
}
