//
//  WebSocketable.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/26.
//

import Foundation

protocol WebSocketable {
    var url: URL? { get }
    var message: Data { get }
}
