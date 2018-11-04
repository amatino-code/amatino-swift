//
//  AmType.swift
//  Amatino
//
//  Created by Hugh Jeremy on 4/7/18.
//

import Foundation

public enum AccountType: Int, Codable {
    case income = 4
    case expense = 5
    case asset = 1
    case liability = 2
    case equity = 3
}

extension AccountType {
    
    public static func nameFor(accountType: AccountType) -> String {
        switch accountType {
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        case .asset:
            return "Asset"
        case .equity:
            return "Equity"
        case .liability:
            return "Liability"
        }
    }
    
    static let allNames = ["Asset", "Liablity", "Equity", "Income", "Expense"]
    static let allCases: [AccountType] = [.asset]

}
