//
//  APIProtocol.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

protocol APIProtocol {
    var url: URL? { get }
    var method: HTTPMethod { get }
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
