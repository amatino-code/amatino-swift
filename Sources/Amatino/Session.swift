//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@blinkybeach.com
//


import Foundation

public class Session {
    
    private let path = "/authorisation/session"
    
    private var api_key: String?
    internal private (set) var id: Int?
    
    typealias callback = (_ session: Session) -> Void
    private let readyCallback: callback?
    
    init (new email: String, secret: String, readyCallback: @escaping (_ session: Session) -> Void) throws {
        
        self.api_key = nil
        self.id = nil
        self.readyCallback = readyCallback
        
        try self.create(secret: secret, email: email)
        
        return
    }
    
    init (existing api_key: String, session_id: Int) {

        self.api_key = api_key
        self.id = session_id
        self.readyCallback = nil
        
        return
    }
    
    private func create(secret: String, email: String) throws -> Void {
        let data: Dictionary<String, Any?> = [
            "secret": secret,
            "email": email
        ]
        let requestData = RequestData(data: data)
        let _ = try AmatinoRequest(path: self.path, data: requestData, session: nil,
                                            urlParams: nil, method: HTTPMethod.POST,
                                            completionHandler: self.loadResponse)

        return
    }
    
    public func delete() -> Void {
        return
    }
    
    private func loadResponse(data: Data?) throws -> Void {
        
    }
    
    internal func signature(path: String, data: RequestData?) -> String {
        return "standin"
    }
    
}
