//
//  Amatino Swift
//  AmatinoObject.swift
//
//  author: hugh@amatino.io
//

internal protocol AmatinoObject: Decodable {}

extension AmatinoObject {
    
    static func loadResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, Self?) -> Void
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let object: Self
        let objects: [Self]
        guard let dataToDecode: Data = data else {
            callback(AmatinoError(.inconsistentInternalState), nil)
            return
        }
        do {
            objects = try decoder.decode(
                [Self].self,
                from: dataToDecode
            )
            guard objects.count > 0 else {
                callback(AmatinoError(.badResponse), nil)
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
    
    static func loadArrayResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, [Self]?) -> Void
    ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let objects: [Self]
        guard let dataToDecode: Data = data else {
            callback(AmatinoError(.inconsistentInternalState), nil)
            return
        }
        do {
            objects = try decoder.decode(
                [Self].self,
                from: dataToDecode
            )
            guard objects.count > 0 else {
                callback(AmatinoError(.badResponse), nil)
                return
            }
            callback(nil, objects)
            return
        } catch {
            callback(error, nil)
            return
        }
    }
    
    static func loadObjectResponse(
        _ error: Error?,
        _ data: Data?,
        _ callback: (Error?, Self?) -> Void
        ) {
        guard error == nil else {callback(error, nil); return}
        let decoder = JSONDecoder()
        let object: Self
        guard let dataToDecode: Data = data else {
            callback(AmatinoError(.badResponse), nil)
            return
        }
        do {
            object = try decoder.decode(
                Self.self,
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
