//
//  Amatino Swift
//  EntityList.swift
//
//  author: hugh@amatino.io
//

import Foundation

public enum EntityListType: String {
    case all = "all"
    case active = "active"
    case deleted = "deleted"
}

public class EntityListError: AmatinoObjectError {}

public class EntityList {}
