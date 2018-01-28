//
//  Amatino Swift
//  AmatinoRequest.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

enum AmatinoRequestError: Error {
    case SessionRequired(description: String)
}

internal class AmatinoRequest: Operation {
    
    private let no_sesh_path = "/authorisation/session"
    private let no_sesh_method = HTTPMethod.POST
    private let missing_session_message = """
    A Session is required for all requests other than
    /authorisation/session + POST
    """
    
    private let path: String
    private let data: Dictionary<String, Any?>?
    private let session: Session?
    private let url_params: String?
    private let method: HTTPMethod
    
    init(
        path: String,
        data: Dictionary<String, Any?>?,
        session: Session?,
        url_params: String?,
        method: HTTPMethod
        ) throws {
        
        self.path = path
        self.data = data
        self.session = session
        self.url_params = url_params
        self.method = method
        
        if self.session == nil && (self.path != no_sesh_path || self.method != no_sesh_method){
            throw AmatinoRequestError.SessionRequired(description: self.missing_session_message)
        }
        
        return
    }
    
}
