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
    private let decoder = JSONDecoder()
    
    init() {
        self.dateFormatter.dateFormat = dateStringFormat
        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
        return
    }
    
    internal func parseStringToDate(_ dateString: String) -> Date? {
        self.dateFormatter.dateFormat = self.dateStringFormat
        return self.dateFormatter.date(from: dateString)
    }

    internal func processResponse<objectForm: Codable>(
        errorClass: ObjectError.Type,
        request: AmatinoRequest?,
        outputType: objectForm.Type,
        requestIndex: Int?
        ) throws -> objectForm {
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
        guard data != nil else {throw InternalLibraryError.InconsistentState()}
        let decodedData = try self.decoder.decode([objectForm].self, from: data!)
        let returnIndex: Int
        if decodedData.count > 1 {
            guard requestIndex != nil else {throw InternalLibraryError.InconsistentState()}
            returnIndex = requestIndex!
        } else {
            returnIndex = 0
        }
        return decodedData[returnIndex]
    }
}
