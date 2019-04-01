//
//  Amatino Swift
//  User.swift
//
//  author: hugh@amatino.io
//

import Foundation

public class User {
    
    public let session: Session

    private let attributes: User.Attributes
    
    private static let path = "/users"
    private static let idKey = "user_id"
    
    public var id: Int { get { return attributes.id } }
    public var email: String? { get { return attributes.email } }
    public var name: String? { get { return attributes.name } }
    public var handle: String? { get { return attributes.handle } }
    public var avatarUrl: String? { get { return attributes.avatarUrl } }
    
    public static let maxSecretLength = 100
    public static let minSecretLength = 12
    public static let minSecretCharacters = 4
    public static let disallowedSecretContent = ["password"]
    public static let maxNameLength = 512
    public static let maxHandleLength = 512
    
    private init (
        _ session: Session,
        _ attributes: User.Attributes
        ) {
        self.session = session
        self.attributes = attributes
    }
    
    private struct Attributes: Decodable {
        
        let id: Int
        let email: String?
        let name: String?
        let handle: String?
        let avatarUrl: String?
        
        enum JSONObjectKeys: String, CodingKey {
            case id = "user_id"
            case email = "email"
            case name = "name"
            case handle = "handle"
            case avatar_url = "avatar_url"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONObjectKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            email = try container.decode(String?.self, forKey: .email)
            name = try container.decode(String?.self, forKey: .name)
            handle = try container.decode(String?.self, forKey: .handle)
            avatarUrl = try container.decode(String?.self, forKey: .avatar_url)
            return
        }
    }
    
    public static func create(
        authenticatedBy session: Session,
        withSecret secret: String,
        named name: String? = nil,
        knownAs handle: String? = nil,
        callback: @escaping (_: Error?, _: User?) -> Void
        ) {
        do {
            let arguments = try User.CreateArguments(
                withSecret: secret,
                named: name,
                knownAs: handle
            )
            User.createMany(
                authenticatedBy: session,
                withArguments: [arguments],
                callback: { (error, users) in
                    guard let users = users else {
                        callback(
                            error ?? AmatinoError(.inconsistentInternalState),
                            nil
                        )
                        return
                    }
                    callback(nil, users[0])
                    return
            })
        } catch {
            callback(error, nil)
            return
        }
    }
    
    public static func createMany(
        authenticatedBy session: Session,
        withArguments arguments: [User.CreateArguments],
        callback: @escaping (_: Error?, _: [User]?) -> Void
    ) {
        do {
            let requestData = try RequestData(arrayData: arguments)
            let _ = try AmatinoRequest(
                path: User.path,
                data: requestData,
                session: session,
                urlParameters: nil,
                method: .POST,
                callback: {(error, data) in
                    let _ = User.asyncInitMany(session, error, data, callback)
            })
        } catch {
            callback(error, nil)
            return
        }
    }
    
    public static func retrieveMany(
        authenticatedBy session: Session,
        withIds ids: [Int],
        callback: @escaping (_: Error?, _: [User]?) -> Void
    ) {
        do {
            let targets = ids.map({UrlTarget.init(
                integerValue: $0,
                key: User.idKey
            )})
            let _ = try AmatinoRequest(
                path: User.path,
                data: nil,
                session: session,
                urlParameters: UrlParameters(targetsOnly: targets),
                method: .GET,
                callback: { (error, data) in
                    let _ = User.asyncInitMany(session, error, data, callback)
            })
        } catch {
            callback(error, nil)
        }
    }
    
    public static func retrieve(
        authenticatedBy session: Session,
        withId id: Int,
        callback: @escaping (_: Error?, _: User?) -> Void
    ) {
        let _ = User.retrieveMany(
            authenticatedBy: session,
            withIds: [id],
            callback: { (error, users) in
                guard let users = users else {
                    callback(
                        error ?? AmatinoError(.inconsistentInternalState),
                        nil
                    )
                    return
                }
                callback(nil, users[0])
        })
        return
    }

    public func delete(callback: @escaping (_: Error?) -> Void) {
        let target = UrlTarget(integerValue: self.id, key: User.idKey)
        do {
            let _ = try AmatinoRequest(
                path: User.path,
                data: nil,
                session: self.session,
                urlParameters: UrlParameters(targetsOnly: [target]),
                method: .DELETE,
                callback: { (error, _) in
                    callback(error)
            })
        } catch {
            callback(error)
        }
        return
    }

    private static func asyncInit(
        _ session: Session,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, User?) -> Void
        ) {
        let _ = User.asyncInitMany(session, error, data, {
            (error, users) in
            guard let users = users else {
                callback(
                    error ?? AmatinoError(.inconsistentInternalState),
                    nil
                ); return
            }
            callback(nil, users[0])
            return
        })
    }
    
    private static func asyncInitMany(
        _ session: Session,
        _ error: Error?,
        _ data: Data?,
        _ callback: @escaping (Error?, [User]?) -> Void
    ) {

        guard let data = data else {
            callback(
                (error ?? AmatinoError(.inconsistentInternalState)),
                nil
            ); return
        }
    
        let users: [User]
        
        do {
            users = try User.decodeMany(session, data)
        } catch {
            callback(error, nil); return
        }
        
        callback(nil, users)
    
    }
    
    private static func decode(
        _ session: Session,
        _ data: Data
        ) throws -> User {
        return try User.decodeMany(session, data)[0]
    }
    
    private static func decodeMany(
        _ session: Session,
        _ data: Data
    ) throws -> [User] {
        
        let decoder = JSONDecoder()
        let attributes = try decoder.decode(
            [User.Attributes].self,
            from: data
        )
        let users = attributes.map({User(session, $0)})
        return users
    }
    
    
    public struct CreateArguments: Encodable {
        
        let secret: String
        let name: String?
        let handle: String?
        
        public init(
            withSecret rawSecret: String,
            named rawName: String? = nil,
            knownAs rawHandle: String? = nil
        ) throws {
            let secret = try User.Secret(rawSecret)
            let name = try User.Name(rawName)
            let handle = try User.Handle(rawHandle)
            self.init(secret, handle, name)
        }
        
        private init(
            _ secret: User.Secret,
            _ handle: User.Handle?,
            _ name: User.Name?
            ) {
            self.secret = secret.rawValue
            self.handle = handle?.rawValue
            self.name = name?.rawValue
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case secret
            case name
            case handle
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.handle, forKey: .handle)
            try container.encode(self.secret, forKey: .secret)
            return
        }
    }
    
    internal struct Secret {
        let rawValue: String
        private var maxLengthError: String { get {
            return "Maximum secret length \(User.maxSecretLength) charecters"
        }}
        private var minLengthError: String { get {
            return "Minimum secret length \(User.minSecretLength) characters"
        }}
        
        init(_ secret: String) throws {
            rawValue = secret
            guard secret.count <= User.maxSecretLength else {
                throw ConstraintError(.maxSecretLength, maxLengthError)
            }
            guard secret.count >= User.minSecretLength else {
                throw ConstraintError(.minSecretLength, minLengthError)
            }
            for disallowedValue in User.disallowedSecretContent {
                if secret.contains(disallowedValue) {
                    throw ConstraintError(
                        .disallowedContent,
                        "Secret contains disallowed content: \(disallowedValue)"
                    )
                }
            }
        }
    }
    
    internal struct Name {
        let rawValue: String?
        private var minLengthError: String { get {
            return "Max name length: \(User.maxNameLength) characters"
        }}
        
        init(_ name: String?) throws {
            rawValue = name
            guard let nameValue = name else { return }
            guard nameValue.count <= User.maxNameLength else {
                throw ConstraintError(.nameLength, minLengthError)
            }
            return
        }
    }
    
    internal struct Handle {
        let rawValue: String?
        private var maxLengthError: String { get {
            return "Max handle length: \(User.maxHandleLength) characters"
        }}
        
        init(_ name: String?) throws {
            rawValue = name
            guard let nameValue = name else { return }
            guard nameValue.count <= User.maxHandleLength else {
                throw ConstraintError(.handleLength, maxLengthError)
            }
            return
        }
    }
    
    public class ConstraintError: AmatinoError {
        public let constraint: Constraint
        public let constraintDescription: String
        
        internal init(_ cause: Constraint, _ description: String? = nil) {
            constraint = cause
            constraintDescription = description ?? cause.rawValue
            super.init(.constraintViolated)
            return
        }
        
        public enum Constraint: String {
            case nameLength = "Max name length exceeded"
            case maxSecretLength = "Max secret length exceeded"
            case minSecretLength = "Secret below minimum length"
            case disallowedContent = "Secret contains disallowed value"
            case handleLength = "Handle exceeds maximum length"
        }
    }
}

