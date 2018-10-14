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
    
    public static func create(
        email: String,
        secret: String,
        callback: @escaping (Error?, Session?) -> Void
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
            throw AmatinoError(.inconsistentInternalState)
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
