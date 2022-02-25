//
//  APIProtocol.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

protocol APIable {
    var url: URL? { get }
    var method: HTTPMethod { get }
}

protocol Gettable: APIable { }

extension Gettable {
    var method: HTTPMethod {
        return .get
    }
}

enum HTTPMethod: CustomStringConvertible {
    case get
    
    var description: String {
        switch self {
        case .get:
            return "GET"
        }
    }
}
