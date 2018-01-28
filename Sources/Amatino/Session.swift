//
//  Amatino Swift
//  Session.swift
//
//  author: hugh@blinkybeach.com
//


import Foundation

public class Session {
    
    private let api_key: String
    private let id: Int
    
    init (new email: String, secret: String, ready: (_ session: Session) -> Void) throws {
        
        self.api_key = "hello"
        self.id = 1
        
    }
    
    init (existing api_key: String, session_id: Int) {

        self.api_key = api_key
        self.id = session_id

    }
    
    private func create() {
        return
    }
    
    private func retrieve() {
        
    }
    
}
