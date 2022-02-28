//
//  MockWebSocketService.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation
@testable import BithumbYagomAcamedy

struct MockWebSocketService: WebSocketServicable {
    typealias completionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    private var webSocketTask: URLSessionWebSocketTaskProviding?
    
    init(webSocketTask: URLSessionWebSocketTaskProviding) {
        self.webSocketTask = webSocketTask
    }
    
    func open(
        webSocketAPI: WebSocketable,
        completionHandler: @escaping completionHandler
    ) {
        guard (webSocketAPI.url) != nil else {
            completionHandler(.failure(WebSocketError.urlIsNil))
            return
        }
        
        webSocketTask?.resume()
        send(to: webSocketAPI.message, completionHandler: completionHandler)
        receive(with: completionHandler)
    }
    
    private func send(
        to message: Data,
        completionHandler: @escaping completionHandler
    ) {
        webSocketTask?.send(
            .data(message)
        ) { error in
            if let error = error {
                completionHandler(.failure(WebSocketError.unknown(error: error)))
            }
        }
    }
    
    private func receive(
        with completionHandler: @escaping completionHandler
    ) {
       webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                completionHandler(.success(message))
            case .failure(let error):
                completionHandler(.failure(WebSocketError.unknown(error: error)))
            }
        }
    }
}
