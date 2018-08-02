//
//  AmatinoDate.swift
//  Amatino
//
//  Created by Hugh Jeremy on 27/7/18.
//

import Foundation

internal struct AmatinoDate {
    
    let decodedDate: Date
    
    internal init (fromString dateString: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = RequestData.dateStringFormat
        guard let date: Date = formatter.date(from: dateString) else {
            throw AmatinoError(.badResponse)
        }
        decodedDate = date
        return
    }
    
}
