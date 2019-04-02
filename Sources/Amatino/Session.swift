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

    public let apiKey: String
    public let userId: Int
    public let sessionId: Int
    
    public func delete(then callback: @escaping (Error?) -> Void) {
        do {
            let _ = try AmatinoRequest(
                path: Session.apiPath,
                data: nil,
                session: self,
                urlParameters: nil,
                method: .DELETE,
                callback: { (error, _) in
                    callback(error)
                }
            )
        } catch {
            callback(error)
            return
        }
    }

    public static func create(
        email: String,
        secret: String,
        then callback: @escaping (Error?, Session?) -> Void
        ) {
        
        let creationData = CreateArguments(secret: secret, email: email)
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
                    let object: Attributes
                    do {
                        object = try decoder.decode(
                            Attributes.self,
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
    
    public static func create(
        email: String,
        secret: String,
        then callback: @escaping (Result<Session, Error>) -> Void
    ) {
        Session.create(email: email, secret: secret) { (error, session) in
            guard let session = session else {
                callback(.failure(error ?? AmatinoError(.inconsistentState)))
                return
            }
            callback(.success(session))
            return
        }
    }
    
    internal init (attributes: Attributes) {
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
            throw AmatinoError(.inconsistentState)
        }

        return signature
    }
    
    public struct Attributes: Codable {
        
        public let apiKey: String
        public let sessionId: Int
        public let userId: Int
        
        enum CodingKeys: String, CodingKey {
            
            case apiKey = "api_key"
            case sessionId = "session_id"
            case userId = "user_id"
            
        }
    }
    
    struct CreateArguments: Codable {
        
        let secret: String?
        let email: String?
        let userId: Int?
        
        init (secret: String, email: String) {
            self.email = email
            self.secret = secret
            userId = nil
            return
        }
        
        init (secret: String, userId: Int) {
            self.secret = secret
            self.userId = userId
            email = nil
            return
        }
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case email = "account_email"
            case secret
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(secret, forKey: .secret)
            try container.encode(email, forKey: .email)
            try container.encode(userId, forKey: .userId)
            return
        }
        
    }

    
}
