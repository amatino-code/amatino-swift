//
//  Amatino Swift
//  AmatinoRequest.swift
//
//  author: hugh@amatino.io
//

import Foundation

internal class AmatinoRequest {
    
    private let agent = "Amatino Swift 0.0.5"
    //private let apiEndpoint = "https://api.amatino.io"
    private let apiEndpoint = "http://127.0.0.1:5000"
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

    private let shouldEncodeDataInUrl: Bool
    
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
        
        if method == .GET && data != nil {
            shouldEncodeDataInUrl = true
        } else {
            shouldEncodeDataInUrl = false
        }
        
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
                guard let httpResponse = response as? HTTPURLResponse else {
                    callback(AmatinoError(.inconsistentInternalState), nil)
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let error: AmatinoError
                    switch httpResponse.statusCode {
                    case 400: error = AmatinoError(.badRequest)
                    case 401: error = AmatinoError(.notAuthenticated)
                    case 402: error = AmatinoError(.subscriptionProblem)
                    case 403: error = AmatinoError(.notAuthorised)
                    case 404: error = AmatinoError(.notFound)
                    case 429: error = AmatinoError(.rateLimit)
                    case 500: error = AmatinoError(.genericServerError)
                    case 502, 503, 504: error = AmatinoError(.serviceDisruption)
                    default: error = AmatinoError(
                        .inconsistentInternalState
                        )
                    }
                    callback(error, nil)
                    return
                }
                callback(nil, data)
                return
        }).resume()
        return
    }
    
    private func buildRequest(
        _ path: String,
        _ data: RequestData?,
        _ session: Session?,
        _ urlParameters: UrlParameters?,
        _ method: HTTPMethod
    ) throws -> URLRequest {
  
        
        let fullURL: String
        
        if urlParameters != nil {
            fullURL = apiEndpoint + path + urlParameters!.paramString
        } else {
            fullURL = apiEndpoint + path
        }
        
        let targetURL: URL?

        if shouldEncodeDataInUrl == true {
            if urlParameters != nil {
                targetURL = URL(string: (fullURL + "&" + data!.asUrlParameter()))
            } else {
                targetURL = URL(string: (fullURL + "?" + data!.asUrlParameter()))
            }
        } else {
            targetURL = URL(string: fullURL)
        }

        guard targetURL != nil else {
            throw AmatinoError(.inconsistentInternalState)
        }

        var request = URLRequest(url: targetURL!)
        request.httpMethod = method.rawValue
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.setValue(agent, forHTTPHeaderField: "User-Agent")
        if data != nil && shouldEncodeDataInUrl == false {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = data!.encodedData
        }
        
        if session != nil {
            let signature = try session!.signature(path: path, data: data)
            let sessionId = String(describing: session!.sessionId)
            request.setValue(signature, forHTTPHeaderField: signatureHeaderName)
            request.setValue(sessionId, forHTTPHeaderField: sessionIdHeaderName)
        }
        
        return request
    }
}
