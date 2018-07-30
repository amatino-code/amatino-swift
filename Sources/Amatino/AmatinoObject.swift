//
//  Amatino Swift
//  AmatinoObject.swift
//
//  author: hugh@amatino.io
//

internal protocol AmatinoObject: Decodable {
    static var errorType: AmatinoObjectError.Type { get }
}

extension AmatinoObject {
    
    static func loadResponse<ObjectType: AmatinoObject>(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, ObjectType?) -> Void,
        _ object: ObjectType.Type
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let object: ObjectType
        let objects: [ObjectType]
        guard let dataToDecode: Data = data else {
            callback(errorType.init(.inconsistentInternalState), nil)
            return
        }
        do {
            objects = try decoder.decode(
                [ObjectType].self,
                from: dataToDecode
            )
            guard objects.count > 0 else {
                callback(errorType.init(.incomprehensibleResponse), nil)
                return
            }
            object = objects[0]
            callback(nil, object)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
    static func loadArrayResponse<ObjectType: AmatinoObject>(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, [ObjectType]?) -> Void,
        _ object: ObjectType.Type
    ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let objects: [ObjectType]
        guard let dataToDecode: Data = data else {
            callback(AmatinoObjectError(.inconsistentInternalState), nil)
            return
        }
        do {
            objects = try decoder.decode(
                [ObjectType].self,
                from: dataToDecode
            )
            guard objects.count > 0 else {
                callback(AmatinoObjectError(.incomprehensibleResponse), nil)
                return
            }
            callback(nil, objects)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
    static func loadObjectResponse<ObjectType: AmatinoObject>(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, ObjectType?) -> Void,
        _ object: ObjectType.Type
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let object: ObjectType
        guard let dataToDecode: Data = data else {
            callback(errorType.init(.inconsistentInternalState), nil)
            return
        }
        do {
            object = try decoder.decode(
                ObjectType.self,
                from: dataToDecode
            )
            callback(nil, object)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
}
