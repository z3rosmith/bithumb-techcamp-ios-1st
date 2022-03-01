//
//  WebSocketServicable.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

protocol WebSocketServicable {
    mutating func open(
        webSocketAPI: WebSocketable,
        completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    )
    
    func close()
}
