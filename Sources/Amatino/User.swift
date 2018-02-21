//
//  Amatino Swift
//  User.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class UserError: AmatinoObjectError {}

public class User {
    
    private let session: Session
    private let readyCallback: (_: User) -> Void
    private let path = "/user"
    private let core = ObjectCore()
    
    private var request: AmatinoRequest? = nil
    private var currentAction: HTTPMethod? = nil
    private var attributes: UserAttributes? = nil
    
    public init(session: Session, readyCallback: @escaping (_ : User) -> Void) throws {

        self.session = session
        self.readyCallback = readyCallback
        
        currentAction = .GET
        request = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: nil,
            method: .GET,
            readyCallback: requestComplete
        )

    }
    
    private func requestComplete() {
        currentAction = nil
        readyCallback(self)
    }
    
    public func describe() throws -> UserAttributes {
        guard currentAction == nil else { throw UserError(.notReady)}
        if (attributes == nil) {
            attributes = try core.processResponse(
                errorClass: UserError.self,
                request: request,
                outputType: UserAttributes.self,
                requestIndex: nil
            )
        }
        guard attributes != nil else { throw InternalLibraryError.InconsistentState() }
        return attributes!
    }
    
}
