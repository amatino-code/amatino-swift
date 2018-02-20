//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class SessionError: AmatinoObjectError {}

public class Session {
    
    public var ready: Bool = false;
    
    internal let core = ObjectCore()
    internal let getPath = "/authorisation/session"

    private var currentAction: HTTPMethod?
    private var apiKey: String?
    private var userId: Int?
    private var id: Int?
    private var request: AmatinoRequest? = nil
    private var attributes: SessionAttributes? = nil
    
    private let readyCallback: ((_ session: Session) -> Void)?

    public init (email: String, secret: String, readyCallback: @escaping (_ session: Session) -> Void) throws {
        
        self.apiKey = nil
        self.id = nil
        self.userId = nil
        self.readyCallback = readyCallback
        try self.create(secret: secret, email: email)

        return
    }
    
    public init (apiKey: String, sessionId: Int, userId: Int) {

        self.apiKey = apiKey
        self.id = sessionId
        self.userId = userId
        self.readyCallback = nil
        self.ready = true

        return
    }
    
    public func describe() throws -> SessionAttributes {
        
        if (apiKey != nil && userId != nil && id != nil) {
            let directAttributes = SessionAttributes(
                apiKey: self.apiKey!,
                sessionId: id!,
                userId: self.userId!
            )
            return directAttributes
        }

        guard currentAction != nil else { throw SessionError(.notReady)}
        if (attributes == nil) {
            attributes = try core.processResponse(
                errorClass: SessionError.self,
                request: request,
                outputType: SessionAttributes.self,
                requestIndex: nil
            )
        }
        guard attributes != nil else { throw InternalLibraryError.InconsistentState() }
        return self.attributes!
    }
    
    private func create(secret: String, email: String) throws -> Void {
        guard readyCallback != nil else { throw InternalLibraryError.InconsistentState() }
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
        guard apiKey != nil else {throw InternalLibraryError.InconsistentState()}
        
        let dataString: String
        if data == nil {
            dataString = ""
        } else {
            dataString = data!.encodedDataString
        }
        
        let timestamp = String(describing: Int(Date().timeIntervalSince1970))

        let dataToHash = timestamp + path + dataString

        let signature = AMSignature.sha512(apiKey!, data:dataToHash)
        guard signature != nil else {throw InternalLibraryError.SignatureHashFailed()}

        return signature!
    }
    
}
