//
//  Amatino Swift
//  ApiFacing.swift
//
//  author: hugh@amatino.io
//

internal protocol ApiFacing {

    var core: ObjectCore { get }
    var path: String { get }
    var batch: Batch? { get }
    var requestIndex: Int? { get }
    var request: AmatinoRequest? { get }

    func actionUrlParameters() throws -> UrlParameters?
    func actionData() throws -> RequestData?
    func requestComplete(request: AmatinoRequest, index: Int)

}
