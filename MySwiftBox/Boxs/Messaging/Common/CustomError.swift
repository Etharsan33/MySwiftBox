//
//  CustomError.swift
//  rodinclip
//
//  Created by ELANKUMARAN Tharsan on 14/03/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

func ==(lhs: CustomError, rhs: CustomError) -> Bool {
    switch (lhs, rhs) {
    case let (.custom(_,_,c), .custom(_,_,f)):
        return c == f
    case let (.unknown(_,_,c), .unknown(_,_,f)):
        return c == f
    case (.network(_,_,_), .network(_,_,_)):
        return true
    case let (.server(_,_,c), .server(_,_,f)):
        return c == f
    case let (.objectMapping(_,_,c), .objectMapping(_,_,f)):
        return c == f
    case let (.client(_,_,c), .client(_,_,f)):
        return c == f
    case let (.download(_,_,c), .download(_,_,f)):
        return c == f
    case let (.credential(_,_,c), .credential(_,_,f)):
        return c == f
        
    default:
        return false
    }
}


/// Errors
///
/// - unknown
/// - network
/// - server
/// - objectMapping
/// - client
/// - download
/// - custom
/// - credential
public enum CustomError : Error {
    case custom(String?, String?, Int?)
    case unknown(String?, String?, Int?)
    case network(String?, String?, Int?)
    case server(String?, String?, Int?)
    case objectMapping(String?, String?, Int?)
    case client(String?, String?, Int?)
    case download(String?, String?, Int?)
    case credential(String?, String?, Int?)
    
    /// Title to display in case we should show the error
    public var alertTitle : String {
        switch self {
        case .credential(let title, _, _):
            guard let string = title else {
                return "ERROR_CREDENTIAL_ALERT_TITLE"
            }
            return string
        case .custom(let title, _, _), .client(let title, _, _):
            guard let string = title else {
                fallthrough
            }
            return string
        default:
            return "ERROR_DEFAULT_ALERT_TITLE"
        }
    }
    
    /// Message to display in case we should show the error
    public var alertMessage : String {
        switch self {
        case .network(_,let message,_):
            guard let string = message else {
                return "ERROR_NETWORK_ALERT_MESSAGE"
            }
            return string
        case .server(_,let message,_):
            guard let string = message else {
                return "ERROR_SERVER_ALERT_MESSAGE"
            }
            return string
        case .credential(_,let message,_):
            guard let string = message else {
                return "ERROR_CREDENTIAL_ALERT_MESSAGE"
            }
            return string
        case .custom(_,let message,_), .client(_,let message,_):
            guard let string = message else {
                fallthrough
            }
            return string
        default:
            return "ERROR_DEFAULT_ALERT_MESSAGE"
        }
    }
    
    /// Custom error code (default 777 provided)
    public var code : Int {
        
        let defaultCode = 777
        
        switch self {
        case .network(_,_, let code):
            guard let code = code else {
                return 7772
            }
            return code
        case .server(_,_, let code):
            guard let code = code else {
                return 7773
            }
            return code
        case .objectMapping(_,_, let code):
            guard let code = code else {
                return 7774
            }
            return code
        case .client(_,_, let code):
            guard let code = code else {
                return 7775
            }
            return code
        case .download(_,_, let code):
            guard let code = code else {
                return 7776
            }
            return code
        case .custom(_,_, let code):
            guard let code = code else {
                return 7777
            }
            return code
        case .credential(_,_, let code):
            guard let code = code else {
                return 7778
            }
            return code
            
        default:
            return defaultCode
        }
        
    }
}

