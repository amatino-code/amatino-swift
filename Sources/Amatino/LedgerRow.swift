//
//  LedgerLine.swift
//  Amatino
//
//  Created by Hugh Jeremy on 19/7/18.
//

import Foundation

public struct LedgerRow: Decodable {
    
    let transactionId: Int64
    let transactionTime: Date
    let description: String
    let opposingAccountId: Int?
    let opposingAccountName: String
    let debit: Decimal
    let credit: Decimal
    let balance: Decimal
    let presentationDebit: String
    let presentationCredit: String
    let presentationBalance: String
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        transactionId = try container.decode(Int64.self)
        let formatter = DateFormatter()
        formatter.dateFormat = RequestData.dateStringFormat
        let rawTransactionTime = try container.decode(String.self)
        guard let txTime: Date = formatter.date(from: rawTransactionTime) else {
            throw AmatinoError(.badResponse)
        }
        transactionTime = txTime
        description = try container.decode(String.self)
        opposingAccountId = try container.decode(Int?.self)
        opposingAccountName = try container.decode(String.self)
        let rawDebit = try container.decode(String.self)
        let rawCredit = try container.decode(String.self)
        let rawBalance = try container.decode(String.self)
        guard let decimalDebit = Decimal(string: rawDebit) else {
            throw AmatinoError(.badResponse)
        }
        guard let decimalCredit = Decimal(string: rawCredit) else {
            throw AmatinoError(.badResponse)
        }
        let magnitude = try Magnitude(fromString: rawBalance)
        presentationDebit = rawDebit
        presentationCredit = rawCredit
        presentationBalance = rawBalance
        debit = decimalDebit
        credit = decimalCredit
        balance = magnitude.decimal
        return
    }
    
    internal enum JSONObjectKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case transactionTime = "transaction_time"
        case description
        case opposingAccountId = "opposing_account_id"
        case opposingAccountName = "opposing_account_name"
        case debit
        case credit
        case balance
    }
    
}
