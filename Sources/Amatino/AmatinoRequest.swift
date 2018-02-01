//
//  Amatino Swift
//  AmatinoRequest.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

enum AmatinoRequestError: Error {
    case SessionRequired(description: String)
    case URLInitialisationFailure()
    case ResponseError()
    case InvalidSession()
}

internal class AmatinoRequest {

    #if DEBUG
    private let apiEndpoint = "127.0.0.1:5000"
    #else
    private let apiEndpoint = "api.amatino.io"
    #endif
    private let apiSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    private let noSessionPath = "/authorisation/session"
    private let noSessionMethod = HTTPMethod.POST
    private let missingSessionMessage = """
    A Session is required for all requests other than
    /authorisation/session + POST
    """
    private let signatureHeaderName = "X-Signature"
    private let sessionIdHeaderName = "X-Session-ID"
    private let completionHandler: (Data?) throws -> Void

    init(
        path: String,
        data: RequestData?,
        session: Session?,
        urlParams: URLParameters?,
        method: HTTPMethod,
        completionHandler: @escaping (Data?) throws -> Void
        ) throws {
        
        self.completionHandler = completionHandler
        
        if session == nil && (path != noSessionPath || method != noSessionMethod) {
            throw AmatinoRequestError.SessionRequired(description: self.missingSessionMessage)
        }
        
        let fullURL: String
        if urlParams != nil {
            fullURL = apiEndpoint + path + urlParams!.toString()
        } else {
            fullURL = apiEndpoint + path
        }
        
        let targetURL = URL(string: fullURL)
        guard targetURL != nil else {throw AmatinoRequestError.URLInitialisationFailure()}
        var request = URLRequest(url: targetURL!)
        request.httpMethod = method.rawValue
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        if session != nil {
            let signature = session!.signature(path: path, data: data)
            guard session!.id != nil else {throw AmatinoRequestError.InvalidSession()}
            let sessionId = String(describing: session!.id)
            request.setValue(signature, forHTTPHeaderField: signatureHeaderName)
            request.setValue(sessionId, forHTTPHeaderField: sessionIdHeaderName)
        }
        
        let task = apiSession.dataTask(with: request, completionHandler: self.processCompletion)
        task.resume()
        
        return
    }
    
    private func processCompletion(data: Data?, response: URLResponse?, error: Error?) -> Void {
        return
    }
    
}
