//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class SessionError: AmatinoObjectError {}

public class Session {
    
    internal let core = ObjectCore()
    internal let getPath = "/session"

    private var currentAction: HTTPMethod?
    private var request: AmatinoRequest? = nil
    private var attributes: SessionAttributes? = nil
    
    private let readyCallback: ((_ session: Session) -> Void)?

    public init (email: String, secret: String, readyCallback: @escaping (_ session: Session) -> Void) throws {

        self.readyCallback = readyCallback
        try self.create(secret: secret, email: email)

        return
    }
    
    public init (apiKey: String, sessionId: Int, userId: Int) {

        attributes = SessionAttributes(
            apiKey: apiKey,
            sessionId: sessionId,
            userId: userId
        )

        self.readyCallback = nil

        return
    }
    
    public func describe() throws -> SessionAttributes {
    
        guard currentAction == nil else { throw SessionError(.notReady) }
        
        if attributes != nil {
            return attributes!
        }

        if (attributes == nil) {
            attributes = try core.processResponse(
                errorClass: SessionError.self,
                request: request,
                outputType: SessionAttributes.self,
                requestIndex: nil
            )
        }
        guard attributes != nil else { throw InternalLibraryError(.InconsistentState) }
        return self.attributes!
    }
    
    private func create(secret: String, email: String) throws -> Void {
        guard currentAction == nil else { throw SessionError(.operationInProgress) }
        guard readyCallback != nil else { throw InternalLibraryError(.InconsistentState) }
        currentAction = .POST
        let data = SessionCreateArguments(secret: secret, email: email)
        let requestData = try RequestData(data: data, overrideListing: true)
        self.request = try AmatinoRequest(
            path: self.getPath,
            data: requestData,
            session: nil,
            urlParameters: nil,
            method: HTTPMethod.POST,
            readyCallback: self.requestComplete
        )

        return
    }
    
    private func requestComplete() -> Void {
        
        currentAction = nil
        self.readyCallback!(self)
    
        return
    }
    
    public func delete() -> Void {
        // Not yet implemented
        return
    }
    
    internal func signature(path: String, data: RequestData?) throws -> String {

        guard currentAction == nil else {throw SessionError(.notReady)}
        let sessionAttributes = try describe()
        
        let dataString: String
        if data == nil {
            dataString = ""
        } else {
            dataString = data!.encodedDataString
        }
        
        let timestamp = String(describing: Int(Date().timeIntervalSince1970))

        let dataToHash = timestamp + path + dataString

        let signature = AMSignature.sha512(sessionAttributes.apiKey, data:dataToHash)
        guard signature != nil else {throw InternalLibraryError(.SignatureHashFailed)}
        
        return signature!
    }
    
    public func retrieveUser(readyCallback: @escaping (_ : User) -> Void) throws {

        guard currentAction == nil else { throw SessionError(.notReady) }
        let _ = try User(session: self, readyCallback: readyCallback)

        return
    }
    
}
