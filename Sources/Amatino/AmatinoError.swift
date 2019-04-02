//
//  AmatinoError.swift
//  Amatino
//
//  Created by Hugh Jeremy on 1/8/18.
//

import Foundation

public class AmatinoError: Error, CustomStringConvertible {
    public let kind: Kind
    public let message: String
    
    public var description: String { get { return self.message }}
    
    internal init(_ kind: Kind) {
        self.kind = kind
        message = kind.rawValue
        return
    }
    
    public enum Kind: String {
        case jsonParseFailed = """
        Amatino Swift was unable to parse the JSON sent by the Amatino API. \
        This likely indicates a bug, please considering opening an issue on \
        GitHub.
        """
        case badResponse = """
        Amatino Swift was not able to understand the response sent by the \
        Amatino API. If this happens repeatedly, there may be a bug in the API.
        """
        case inconsistentState = """
        Amatino Swift has entered an unexpected state from which it cannot \
        recover. Please consider filing a bug report on GitHub.
        """
        case notFound = "A requested resource could not be found"
        case notAuthorised = """
        You are not authorised to access a requested resource.
        """
        case notAuthenticated = """
        Your request was not authenticated. Your Session may have expired or \
        been deleted. Consider creating a new Session.
        """
        case badRequest = """
        The Amatino API could not understand your request, it may be missing a \
        required parameter, or be composed of incorrect types. It is the \
        responsibility of this library (Amatino Swift) to supply correctly \
        formed requests, so please consider filing a bug report on GitHub.
        """
        case genericServerError = """
        The Amatino API replied with a generic error response, indicating that \
        it has failed internally. Either Amatino is experiencing temporary \
        disruption, or there is a bug in the API.
        """
        case constraintViolated = """
        Input data violates a constraint. For example, a description may be \
        too long.
        """
        case subscriptionProblem = """
        Your Amatino subscription does not allow you to perfom this action. \
        Your payment method may have expired, or your plan may be disabled. \
        Please visit https://amatino.io/billing or contact support@amatino.io
        """
        case serviceDisruption = """
        Amatino is experiencing a service disruption. This should be \
        temporary. Check the @amatinoapi Twitter feed and \
        https://amatino.io/blog/ for service updates.
        """
        case rateLimit = """
        You have hit the Amatino API rate limiter. You might try batching your \
        requests (e.g. creating 10 Transactions at once). If your \
        implementation requires a higher rate limit, or your believe you are \
        being erroneously limited (e.g. behind a corporate or university NAT), \
        please contact support@amatino.io
        """
    }
}


