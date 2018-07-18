//
//  GlobalUnitList.swift
//  Amatino
//
//  Created by Hugh Jeremy on 18/7/18.
//

import Foundation

class GlobalUnitList {
    
    private static let path = "/units/list"
    
    public let units: [GlobalUnit]
    
    private init (units: [GlobalUnit]) {
        self.units = units
        return
    }
    
    public static func retrieve(
        session: Session,
        callback: @escaping (Error?, GlobalUnitList?) -> Void
        ) throws {
        
        let _ = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: nil,
            method: .GET,
            callback: { (error, data) in
                guard error == nil else { callback(error, nil); return }
                let decodedUnits: [GlobalUnit]
                let decoder = JSONDecoder()
                do {
                    decodedUnits = try decoder.decode(
                        [GlobalUnit].self,
                        from: data!
                    )
                } catch {
                    callback(error, nil)
                    return
                }
                let globalUnitList = GlobalUnitList(units: decodedUnits)
                callback(nil, globalUnitList)
                return
        })
        
    }
    
}
