//
//  Amatino Swift
//  RegionList.swift
//
//  author: hugh@blinkbeach.com
//

import Foundation

public class RegionListError: AmatinoObjectError {}

public class RegionList {
    
    public let session: Session

    private let core = ObjectCore()
    private let path = "/regions"

    private let readyCallback: (_: RegionList) -> Void

    private var request: AmatinoRequest?
    private var currentAction: HTTPMethod?
    private var attributes: RegionListAttributes? = nil

    public init (session: Session, readyCallback: @escaping (_: RegionList) -> Void) throws {

        self.session = session
        self.readyCallback = readyCallback

        currentAction = .GET
        
        request = try AmatinoRequest(
            path: path,
            data: nil,
            session: session,
            urlParameters: nil,
            method: .GET,
            readyCallback: requestComplete
        )
        
        return
    }

    private func requestComplete() {

        currentAction = nil
        readyCallback(self)

        return
    }
    
    public func describe() throws -> RegionListAttributes {
        guard currentAction == nil else { throw RegionListError(.notReady) }
        if attributes == nil {
            attributes = try core.processResponse(
                errorClass: RegionListError.self,
                request: request,
                outputType: RegionListAttributes.self,
                requestIndex: nil
            )
        }
        guard attributes != nil else { throw InternalLibraryError(.InconsistentState) }
        return attributes!
    }

}
