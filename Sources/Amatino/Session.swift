//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@amatino.io
//


import Foundation

internal class SessionError: ObjectError {}

public class Session {
    
    public var ready: Bool = false;
    
    internal let core = ObjectCore()
    internal let getPath = "/authorisation/session"

    private var currentAction: HTTPMethod?
    private var api_key: String?
    private var request: AmatinoRequest? = nil

    internal private (set) var id: Int?
    
    private let readyCallback: ((_ session: Session) -> Void)?

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
        self.ready = true

        return
    }
    
    private func create(secret: String, email: String) throws -> Void {
        let data = SessionCreateArguments(secret: secret, email: email)
        let requestData = try RequestData(data: data)
        self.request = try AmatinoRequest(
            path: self.getPath,
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
    
    internal func signature(path: String, data: RequestData?) throws -> String {

        guard ready == true else {throw SessionError(.notReady)}
        guard api_key != nil else {throw InternalLibraryError.InconsistentState()}
        
        let dataString: String
        if data == nil {
            dataString = ""
        } else {
            dataString = data!.encodedDataString
        }
        
        let timestamp = String(describing: Int(Date().timeIntervalSince1970))

        let dataToHash = timestamp + path + dataString

        let signature = AMSignature.sha512(api_key!, data:dataToHash)
        guard signature != nil else {throw InternalLibraryError.SignatureHashFailed()}

        return signature!
    }
    
}
