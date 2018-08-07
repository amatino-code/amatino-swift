//
//  Amatino Swift
//  CustomUnit.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class CustomUnit: AmatinoObject, Decodable, Unit  {
    
    public static let maxNameLength = 1024
    public static let maxDescriptionLength = 1024
    public static let minCodeLength = 3
    public static let maxCodeLength = 64
    public static let minExponentSize = 0
    public static let maxExponentSize = 6
    
    internal static let urlKey = "custom_unit_id"
    internal static let path = "/custom_units"
    
    public let code: String
    public let id: Int
    public let name: String
    public let priority: Int
    public let description: String
    public let exponent: Int
    
    public static func create(
        session: Session,
        entity: Entity
        ) {
        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        priority = try container.decode(Int.self, forKey: .priority)
        description = try container.decode(String.self, forKey: .description)
        exponent = try container.decode(Int.self, forKey: .exponent)
        return
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "custom_unit_id"
        case code
        case name
        case priority
        case description
        case exponent
    }
    
    public struct CreationArguments: Encodable {
        let code: Code
        let name: Name
        let priority: Int
        let description: Description
        let exponent: Int
        
        init (
            code: String,
            name: String,
            priority: Int,
            description: String,
            exponent: Int
            ) throws {
            self.code = try Code(code)
            self.name = try Name(name)
            self.description = try Description(description)
            self.priority = priority
            self.exponent = exponent
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: JSONObjectKeys.self)
            try container.encode(code.rawValue, forKey: .code)
            try container.encode(name.rawValue, forKey: .name)
            try container.encode(description.rawValue, forKey: .description)
            try container.encode(priority, forKey: .priority)
            try container.encode(exponent, forKey: .exponent)
            return
        }
        
        enum JSONObjectKeys: String, CodingKey {
            case code
            case name
            case description
            case priority
            case exponent
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
            case descriptionLength = "Maximum description length exceeded"
            case nameLength = "Maximum name length exceeded"
            case codeLengthExceeded  = "Maximum code length exceeded"
            case codeLengthTooShort = "Code length below minimum"
            case maxExponentSize = "Exponent is too large"
            case minExponentSize = "Exponent below minimum value"
        }
        
    }
    
    internal struct Name {
        let rawValue: String
        init(_ name: String) throws {
            guard name.count <= CustomUnit.maxNameLength else {
                throw ConstraintError(.nameLength)
            }
            rawValue = name
            return
        }
    }
    
    internal struct Description {
        let rawValue: String
        init(_ description: String) throws {
            guard description.count <= CustomUnit.maxDescriptionLength else {
                throw ConstraintError(.descriptionLength)
            }
            rawValue = description
            return
        }
    }
    
    internal struct Code {
        let rawValue: String
        init(_ code: String) throws {
            guard code.count <= CustomUnit.maxCodeLength else {
                throw ConstraintError(.codeLengthExceeded)
            }
            guard code.count >= CustomUnit.minCodeLength else {
                throw ConstraintError(.codeLengthTooShort)
            }
            rawValue = code
            return
        }
    }
    
    internal struct Exponent {
        let rawValue: Int
        init(_ exponent: Int) throws {
            guard exponent <= CustomUnit.maxExponentSize else {
                throw ConstraintError(.maxExponentSize)
            }
            guard exponent >= CustomUnit.minExponentSize else {
                throw ConstraintError(.minExponentSize)
            }
            rawValue = exponent
            return
        }
    }
}
