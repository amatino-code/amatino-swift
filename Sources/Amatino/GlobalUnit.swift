//
//  Amatino Swift
//  GlobalUnit.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class GlobalUnitError: AmatinoObjectError {}

public class GlobalUnit: Encodable  {
    
    private static let urlKey = "global_unit_id"
    private static let path = "/units"
    
    public let code: String
    public let id: Int
    public let name: String
    public let priority: Int
    public let description: String
    public let exponent: Int
    
    internal init(attributes: GlobalUnitAttributes) {
        
        code = attributes.code
        id = attributes.unitId
        name = attributes.name
        priority = attributes.priority
        description = attributes.description
        exponent = attributes.exponent
        return
    }
    
    public static func retrieve(
        unitId: Int,
        session: Session,
        callback: @escaping (_: Error?, _: GlobalUnit?) -> Void
    ) -> Void {
        
        let target = UrlTarget(integerValue: unitId, key: urlKey)
        let urlParameters = UrlParameters(targetsOnly: [target])
        
        do {
            let _ = try AmatinoRequest(
                path: path,
                data: nil,
                session: session,
                urlParameters: urlParameters,
                method: .GET,
                callback: {(error: Error?, data: Data?) in
                    guard error == nil else {callback(error, nil); return}
                    let decoder = JSONDecoder()
                    let object: GlobalUnitAttributes
                    do {
                        object = try decoder.decode(
                            [GlobalUnitAttributes].self,
                            from: data!
                        )[0]
                    } catch {
                        let error = GlobalUnitError(.badResponse)
                        callback(error, nil)
                        return
                    }
                    let globalUnit = GlobalUnit(attributes: object)
                    callback(nil, globalUnit)
                    return
            })
        } catch {
            callback(error, nil)
        }

    }
    
    enum CodingKeys: String, CodingKey {
        case id = "global_unit_id"
    }
}

