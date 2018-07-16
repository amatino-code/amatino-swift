//
//  Amatino Swift
//  AmatinoRequest.swift
//
//  author: hugh@amatino.io
//

import Foundation

enum AmatinoRequestError: Error {
    case SessionRequired(description: String)
    case URLInitialisationFailure()
    case ResponseError()
    case InvalidSession()
    case EmptyResponse()
    case JsonParse()
}

internal class AmatinoRequest {
    
    private let agent = "Amatino Swift 0.0.2"
    private let apiEndpoint = "https://api.amatino.io"
    private static let apiSession = URLSession(
        configuration: URLSessionConfiguration.ephemeral
    )
    private let noSessionPath = "session"
    private let noSessionMethod = HTTPMethod.POST
    private let missingSessionMessage = """
    A Session is required for all requests other than /authorisation/session +
    POST
    """
    private let signatureHeaderName = "X-Signature"
    private let sessionIdHeaderName = "X-Session-ID"
    
    internal private(set) var data: Data? = nil;
    internal private(set) var response: URLResponse? = nil;
    internal private(set) var error: Error? = nil;
    
    init(
        path: String,
        data: RequestData?,
        session: Session?,
        urlParameters: UrlParameters?,
        method: HTTPMethod,
        callback: @escaping (Error?, Data?) -> Void
        ) throws {
        
        let request = try buildRequest(
            path,
            data,
            session,
            urlParameters,
            method
        )
        
        let _ = AmatinoRequest.apiSession.dataTask(
            with: request,
            completionHandler: {(
                data: Data?,
                response: URLResponse?,
                error: Error?
            ) in
                if error != nil {
                    callback(error, nil)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        callback(AmatinoRequestError.ResponseError(), nil)
                        // To Do - Descriptive error responses
                        return
                }
                callback(nil, data)
        }).resume()
        return
    }
    
    private static func executeTask(
        request: URLRequest,
        taskCallback: @escaping (Error?, Data?) -> Void
        ) {
        
        let _ = AmatinoRequest.apiSession.dataTask(
            with: request,
            completionHandler: {(
                data: Data?,
                response: URLResponse?,
                error: Error?
                ) in
                if error != nil {
                    taskCallback(error, nil)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        taskCallback(AmatinoRequestError.ResponseError(), nil)
                        // To Do - Descriptive error responses
                        return
                }
                taskCallback(nil, data)
        }).resume()
    }
    
    private func buildRequest(
        _ path: String,
        _ data: RequestData?,
        _ session: Session?,
        _ urlParameters: UrlParameters?,
        _ method: HTTPMethod
    ) throws -> URLRequest {
        
        /*
        if session == nil && (
            path != noSessionPath || method != noSessionMethod
            ) {
            print(method)
            print(path)
            throw AmatinoRequestError.SessionRequired(
                description: self.missingSessionMessage
            )
        }
        */
        
        let fullURL: String
        if urlParameters != nil {
            fullURL = apiEndpoint + path + urlParameters!.paramString
        } else {
            fullURL = apiEndpoint + path
        }
        let targetURL = URL(string: fullURL)
        guard targetURL != nil else {
            throw AmatinoRequestError.URLInitialisationFailure()
        }
        var request = URLRequest(url: targetURL!)
        request.httpMethod = method.rawValue
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.setValue(agent, forHTTPHeaderField: "User-Agent")
        if data != nil {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = data!.encodedData
        }
        
        if session != nil {
            print(session!)
            let signature = try session!.signature(path: path, data: data)
            let sessionId = String(describing: session!.sessionId)
            request.setValue(signature, forHTTPHeaderField: signatureHeaderName)
            request.setValue(sessionId, forHTTPHeaderField: sessionIdHeaderName)
        }
        
        return request
    }
}
