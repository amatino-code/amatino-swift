//
//  Unit.swift
//  Amatino
//
//  Created by Hugh Jeremy on 7/8/18.
//

import Foundation

internal protocol Unit: AmatinoObject {
    
    static var urlKey: String { get }
    static var path: String { get }
    
    var code: String { get }
    var id: Int { get }
    var name: String { get }
    var priority: Int { get }
    var description: String { get }
    var exponent: Int { get }
    
}

extension Unit {
    public static func retrieve(
        unitId: Int,
        session: Session,
        callback: @escaping (_: Error?, _: Self?) -> Void
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
                    let _ = loadResponse(error, data, callback)
            })
        } catch {
            callback(error, nil)
        }
        return
    }
}
