//
//  Amatino Swift
//  Entity.swift
//
//  author: hugh@amatino.io
//
import Foundation

public class EntityError: AmatinoObjectError {}

internal  class Entity {
    let id: String
    
    init (id: String) {
        self.id = id
    }
}
