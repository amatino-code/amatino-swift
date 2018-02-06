//
//  Amatino Swift
//  ApiFacing.swift
//
//  author: hugh@blinkybeach.com
//

internal protocol ApiFacing {
    
    var core: ObjectCore { get }
    var path: String { get }
    var batch: Batch? { get }
    var requestIndex: Int? { get }
    var request: AmatinoRequest? { get }
    
    func formActionUrlParameters() -> UrlParameters
    func formActionData() throws -> RequestData
    func requestComplete(request: AmatinoRequest, index: Int)
    
}
