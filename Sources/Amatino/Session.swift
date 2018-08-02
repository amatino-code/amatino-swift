//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@amatino.io
//


import Foundation

public class SessionError: AmatinoError {}

public class Session {

    internal static let apiPath = "/session"

    private let apiKey: String
    private let userId: Int
    internal let sessionId: Int
    
    public static func create(
        email: String,
        secret: String,
        callback: @escaping (Error?, Session?) -> Void
        ) {
        
        let creationData = SessionCreateArguments(secret: secret, email: email)
        let requestData: RequestData
        do {
            requestData = try RequestData(
                data: creationData,
                overrideListing: true
            )
        } catch {
            callback(error, nil)
            return
        }
        
        do {
            let _ = try AmatinoRequest(
                path: Session.apiPath,
                data: requestData,
                session: nil,
                urlParameters: nil,
                method: HTTPMethod.POST,
                callback: {(error: Error?, data: Data?) -> Void in
                    guard error == nil else {callback(error, nil); return}
                    let decoder = JSONDecoder()
                    let object: SessionAttributes
                    do {
                        object = try decoder.decode(
                            SessionAttributes.self,
                            from: data!
                        )
                    } catch {
                        let error = SessionError(.badResponse)
                        callback(error, nil)
                        return
                    }
                    let session = Session(attributes: object)
                    callback(nil, session)
                    return
                })
        } catch {
            callback(error, nil)
        }
        return
    }
    
    internal init (attributes: SessionAttributes) {
        apiKey = attributes.apiKey
        userId = attributes.userId
        sessionId = attributes.sessionId
        return
    }
    
    public init (apiKey: String, sessionId: Int, userId: Int) {
        self.apiKey = apiKey
        self.sessionId = sessionId
        self.userId = userId
        return
    }

    internal func signature(path: String, data: RequestData?) throws -> String {

        let dataString: String
        if data == nil {
            dataString = ""
        } else {
            dataString = data!.encodedDataString
        }
        
        let timestamp = String(describing: Int(Date().timeIntervalSince1970))
        let dataToHash = timestamp + path + dataString

        guard let signature = AMSignature.sha512(apiKey, data:dataToHash) else {
            throw InternalLibraryError(.SignatureHashFailed)
        }

        return signature
    }
    
}
