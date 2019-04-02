//
//  Performance.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/8/18.
//

import Foundation

public final class Performance: EntityObject, Denominated {
    
    internal init(
        _ entity: Entity,
        _ attributes: Performance.Attributes
        ) {
        self.entity = entity
        self.attributes = attributes
        return
    }
    
    internal let attributes: Performance.Attributes
    
    private static let path = "/performances"
    
    public let entity: Entity
    public var session: Session { get { return entity.session } }
    
    public var startTime: Date { get { return attributes.startTime } }
    public var endTime: Date { get { return attributes.endTime } }
    public var generatedTime: Date { get { return attributes.generatedTime } }
    public var globalUnitId: Int? { get { return attributes.globalUnitId } }
    public var customUnitId: Int? { get { return attributes.customUnitId } }
    public var incomeAccounts: Array<Node> {
        get { return attributes.incomeAccounts }
    }
    public var expenseAccounts: Array<Node> {
        get { return attributes.expenseAccounts }
    }
    public var depth: Int { get { return attributes.depth } }
    
    private var entityId: String { get { return attributes.entityId } }
    
    public static func retrieve(
        for entity: Entity,
        startingAt startTime: Date,
        endingAt endTime: Date,
        denominatedIn denomination: Denomination,
        toDepth depth: Int? = nil,
        then callback: @escaping (Error?, Performance?) -> Void
    ) {
        let arguments = Performance.RetrievalArguments(
            startTime: startTime,
            endTime: endTime,
            denomination: denomination,
            depth: depth
        )
        Performance.executeRetrieval(entity, arguments, callback)
        return
    }
    
    public static func retrieve(
        for entity: Entity,
        startingAt start: Date,
        endingAt end: Date,
        denominatedIn denomination: Denomination,
        toDepth depth: Int? = nil,
        then callback: @escaping (Result<Performance, Error>) -> Void
    ) {
        Performance.retrieve(
            for: entity,
            startingAt: start,
            endingAt: end,
            denominatedIn: denomination
        ) { (error, performance) in
            guard let performance = performance else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(performance))
            return
        }
    }

    private static func executeRetrieval(
        _ entity: Entity,
        _ arguments: Performance.RetrievalArguments,
        _ callback: @escaping (Error?, Performance?) -> Void
        ) {
        do {
            let _ = try AmatinoRequest(
                path: Performance.path,
                data: try RequestData(data: arguments, overrideListing: true),
                session: entity.session,
                urlParameters: UrlParameters(singleEntity: entity),
                method: .GET
            ) { (error, data) in
                let _ = asyncInitSolo(
                    entity,
                    callback,
                    error,
                    data
                )
                return
            }
        } catch {
            callback(error, nil)
        }
    }
    
    internal struct Attributes: Decodable {
        let startTime: Date
        let endTime: Date
        let generatedTime: Date
        let globalUnitId: Int?
        let customUnitId: Int?
        let incomeAccounts: Array<Node>
        let expenseAccounts: Array<Node>
        let depth: Int
        let entityId: String
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(
                keyedBy: JSONObjectKeys.self
            )
            entityId = try container.decode(String.self, forKey: .entityId)
            startTime = try AmatinoDate(
                fromString: container.decode(
                    String.self,
                    forKey: .startTime
                )
            ).decodedDate
            endTime = try AmatinoDate(
                fromString: container.decode(
                    String.self,
                    forKey: .endTime
                )
            ).decodedDate
            generatedTime = try AmatinoDate(
                fromString: container.decode(
                    String.self,
                    forKey: .generatedTime
                )
            ).decodedDate
            globalUnitId = try container.decode(Int?.self, forKey: .globalUnit)
            customUnitId = try container.decode(Int?.self, forKey: .customUnit)
            incomeAccounts = try TreeNode.decodeNodes(
                container: container, key: .income
            )
            expenseAccounts = try TreeNode.decodeNodes(
                container: container, key: .expenses
            )
            depth = try container.decode(Int.self, forKey: .depth)
            return
        }

        enum JSONObjectKeys: String, CodingKey {
            case entityId = "entity_id"
            case startTime = "start_time"
            case endTime = "end_time"
            case generatedTime = "generated_time"
            case globalUnit = "global_unit_denomination"
            case customUnit = "custom_unit_denomination"
            case income
            case expenses
            case depth
        }
    }
    
    internal struct RetrievalArguments: Encodable {
        let startTime: Date
        let endTime: Date
        let globalUnitId: Int?
        let customUnitId: Int?
        let depth: Int?
        
        internal func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(globalUnitId, forKey: .globalUnitId)
            try container.encode(customUnitId, forKey: .customUnitId)
            try container.encode(depth, forKey: .depth)
            return
        }
        
        public init(
            startTime: Date,
            endTime: Date,
            denomination: Denomination,
            depth: Int?
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
            self.startTime = startTime
            self.endTime = endTime
            self.depth = depth
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case startTime = "start_time"
            case endTime = "end_time"
            case globalUnitId = "global_unit_denomination"
            case customUnitId = "custom_unit_denomination"
            case depth
        }
    }
}
