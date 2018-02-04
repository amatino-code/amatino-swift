//
//  Amatino Swift
//  ObjectCore.swift
//
//  author: hugh@blinkybeach.com
//

import Foundation

internal class ObjectCore {
    
    private let dateFormatter = DateFormatter()
    private let dateStringFormat = "yyyy-MM-dd_HH:mm:ss.SSSSSS"
    
    init() {
        self.dateFormatter.dateFormat = dateStringFormat
        return
    }
    
    internal func parseStringToDate(_ dateString: String) -> Date? {
        self.dateFormatter.dateFormat = self.dateStringFormat
        return self.dateFormatter.date(from: dateString)
    }

    internal func processResponse(errorClass: ObjectError.Type, request: AmatinoRequest?) throws -> Dictionary<String, Any> {
        guard request != nil else {throw InternalLibraryError.RequestNilOnReady()}
        if request?.error != nil {
            throw request!.error!
        }
        let response = request?.response as? HTTPURLResponse
        guard response != nil else {throw InternalLibraryError.ResponseCastFailed()}
        if response?.statusCode != 200 {
            if response?.statusCode == 400 {
                throw errorClass.init(.badRequest)
            }
            if response?.statusCode == 401 {
                throw errorClass.init(.notAuthenticated)
            }
            if response?.statusCode == 403 {
                throw errorClass.init(.notAuthorised)
            }
            if response?.statusCode == 404 {
                throw errorClass.init(.notFound)
            }
            if response?.statusCode == 500 {
                throw errorClass.init(.genericServerError)
            }
        }
        let data = request?.data
        guard data != nil else {throw InternalLibraryError.ResponseDataMissing()}
        let parsedData = try JSONSerialization.jsonObject(with: data!) as? Dictionary<String, Any>
        guard parsedData != nil else {throw errorClass.init(.jsonParseFailed)}
        return parsedData!
    }
    
}
