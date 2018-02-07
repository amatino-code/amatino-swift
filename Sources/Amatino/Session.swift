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
    
    internal var ready = false
    internal var request: AmatinoRequest? = nil
    
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
        let requestData = try RequestData(data: data)
        self.request = try AmatinoRequest(
            path: self.path,
            data: requestData,
            session: nil,
            urlParameters: nil,
            method: HTTPMethod.POST,
            readyCallback: self.notifyReady
        )

        return
    }
    
    private func notifyReady() -> Void {
        self.ready = true
        self.readyCallback!(self)
        return
    }
    
    public func delete() -> Void {
        return
    }
    
    internal func signature(path: String, data: RequestData?) -> String {
        return "standin"
    }
    
}
