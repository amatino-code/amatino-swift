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
