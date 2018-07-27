//
//  AmatinoDate.swift
//  Amatino
//
//  Created by Hugh Jeremy on 27/7/18.
//

import Foundation

internal struct AmatinoDate {
    
    let decodedDate: Date
    
    internal init (
        fromString dateString: String,
        withError ErrorType: AmatinoObjectError.Type
        ) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = RequestData.dateStringFormat
        guard let date: Date = formatter.date(from: dateString) else {
            throw ErrorType.init(.incomprehensibleResponse)
        }
        decodedDate = date
        return
    }
    
}
