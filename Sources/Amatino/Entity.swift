//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class EntityError: AmatinoObjectError {}

public class Entity {
    let id: String
    
    init (id: String) {
        self.id = id
    }
}
