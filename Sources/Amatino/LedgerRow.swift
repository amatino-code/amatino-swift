//
//  LedgerLine.swift
//  Amatino
//
//  Created by Hugh Jeremy on 19/7/18.
//

import Foundation

public class LedgerRowError: AmatinoObjectError {}

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
            throw LedgerRowError(.incomprehensibleResponse)
        }
        transactionTime = txTime
        description = try container.decode(String.self)
        opposingAccountId = try container.decode(Int?.self)
        opposingAccountName = try container.decode(String.self)
        let rawDebit = try container.decode(String.self)
        let rawCredit = try container.decode(String.self)
        let rawBalance = try container.decode(String.self)
        guard let decimalDebit = Decimal(string: rawDebit) else {
            throw LedgerRowError(.incomprehensibleResponse)
        }
        guard let decimalCredit = Decimal(string: rawCredit) else {
            throw LedgerRowError(.incomprehensibleResponse)
        }
        let magnitude = try Magnitude(
            fromString: rawBalance,
            withError: LedgerRowError.self
        )
        presentationDebit = rawDebit
        presentationCredit = rawCredit
        presentationBalance = rawBalance
        debit = decimalDebit
        credit = decimalCredit
        balance = magnitude.decimal
        return
    }
    
    internal enum CodingKeys: String, CodingKey {
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
