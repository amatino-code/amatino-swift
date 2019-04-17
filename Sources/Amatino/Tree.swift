//
//  Tree.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public final class Tree: EntityObject, Sequence, Denominated {

    internal init(
        _ entity: Entity,
        _ attributes: Tree.Attributes
        ) {
        self.entity = entity
        self.attributes = attributes
        return
    }

    internal let attributes: Tree.Attributes
    
    private static let path =  "/trees"
    
    public let entity: Entity
    public var session: Session { get { return entity.session } }

    public var balanceTime: Date { get { return attributes.balanceTime } }
    public var generatedTime: Date { get { return attributes.generatedTime } }
    public var globalUnitId: Int? { get { return attributes.globalUnitId } }
    public var customUnitId: Int? { get { return attributes.customUnitId } }
    public var accounts: Array<Node> { get { return attributes.accounts } }
    public var flatAccounts: Array<Node> {
        get {
            func recurse(_ node: Node) -> Array<Node> {
                if node.children.count < 1 { return [node] }
                return node.children.map( {recurse($0)} ).reduce(
                    [node],
                    {x, y in x + y}
                )
            }
            return self.accounts.map( {recurse($0)} ).reduce(
                Array<Node>(),
                {x, y in x + y}
            )
        }
    }
    
    private var entityid: String { get { return attributes.entityId } }
        
    public static func retrieve(
        for entity: Entity,
        denominatedIn denomination: Denomination,
        balancingAt balanceTime: Date? = nil,
        then callback: @escaping (_: Error?, _: Tree?) -> Void
    )  {
        
        let arguments = Tree.RetrievalArguments(
            denomination: denomination,
            balanceTime: balanceTime ?? Date()
        )
        do {
            let _ = try Tree.executeRetrieval(
                entity,
                arguments,
                callback
            )
        } catch {
            callback(error, nil)
        }
        return
    }
    
    public static func retrieve(
        for entity: Entity,
        denominatedIn denomination: Denomination,
        balancingAt balanceTime: Date? = nil,
        then callback: @escaping (Result<Tree, Error>) -> Void
    ) {
        Tree.retrieve(
            for: entity,
            denominatedIn: denomination
        ) { (error, tree) in
            guard let tree = tree else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(tree))
            return
        }
    }

    
    private static func executeRetrieval(
        _ entity: Entity,
        _ arguments: Tree.RetrievalArguments,
        _ callback: @escaping (_: Error?, _: Tree?) -> Void
        ) throws {
        let _ = try AmatinoRequest(
            path: Tree.path,
            data: RequestData(data: arguments, overrideListing: true),
            session: entity.session,
            urlParameters: UrlParameters(singleEntity: entity),
            method: .GET,
            callback: { (error, data) in
                let _ = asyncInitSolo(
                    entity,
                    callback,
                    error,
                    data
                )
                return
        })
    }
    
    internal struct Attributes: Decodable {
        let entityId: String
        let balanceTime: Date
        let generatedTime: Date
        let globalUnitId: Int?
        let customUnitId: Int?
        let accounts: Array<Node>
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            entityId = try container.decode(String.self, forKey: .entityId)
            balanceTime = try AmatinoDate(
                fromString: container.decode(String.self, forKey: .balanceTime)
            ).decodedDate
            generatedTime = try AmatinoDate(
                fromString: container.decode(
                    String.self,
                    forKey: .generatedTime
                )
            ).decodedDate
            globalUnitId = try container.decode(Int?.self, forKey: .globalUnit)
            customUnitId = try container.decode(Int?.self, forKey: .customUnit)
            accounts = try TreeNode.decodeNodes(
                container: container, key: .tree
            )
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case entityId = "entity_id"
            case balanceTime = "balance_time"
            case generatedTime = "generated_time"
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case tree
        }
    }
    
    internal struct RetrievalArguments: Encodable {
        let balanceTime: Date
        let globalUnitId: Int?
        let customUnitId: Int?
        
        enum JSONObjectKeys: String, CodingKey {
            case balanceTime =  "balance_time"
            case globalUnitId = "global_unit_denomination"
            case customUnitId = "custom_unit_denomination"
        }
        
        public init(
            denomination: Denomination,
            balanceTime: Date
            ) {
            if let customUnit = denomination as? CustomUnit {
                self.customUnitId = customUnit.id
                self.globalUnitId = nil
            } else if let globalUnit = denomination as? GlobalUnit {
                self.globalUnitId = globalUnit.id
                self.customUnitId = nil
            } else {
                fatalError("Unknown Denomination type")
            }
            self.balanceTime = balanceTime
            return
        }
        
        internal func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(balanceTime, forKey: .balanceTime)
            try container.encode(globalUnitId, forKey: .globalUnitId)
            try container.encode(customUnitId, forKey: .customUnitId)
            return
        }
        
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(accounts)
    }
    
    public struct Iterator: IteratorProtocol {
        let accounts: [Node]
        var index = 0
        
        init(_ accounts: [Node]) {
            self.accounts = accounts
        }
        
        public mutating func next() -> Node? {
            guard index + 1 <= accounts.count else {
                return nil
            }
            let nodeToReturn = accounts[index]
            index += 1
            return nodeToReturn
        }
    }
    
}
