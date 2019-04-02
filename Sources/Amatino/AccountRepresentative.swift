//
//  AccountRepresentation.swift
//  Amatino
//
//  Created by Hugh Jeremy on 14/11/18.
//  Copyright © 2018 Amatino Pty Ltd. All rights reserved.
//

import Foundation

public protocol AccountRepresentative {
    
    var accountId: Int { get }
    var name: String { get }
    var type: AccountType { get }

}
