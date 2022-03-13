//
//  MockWebSocketService.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation
@testable import BithumbYagomAcamedy

struct MockWebSocketService: WebSocketServicable {
    
    // MARK: - Typealias
    
    typealias CompletionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    // MARK: - Property
    
    private var webSocketTask: URLSessionWebSocketTaskProviding?
    
    // MARK: - Init
    
    init(webSocketTask: URLSessionWebSocketTaskProviding) {
        self.webSocketTask = webSocketTask
    }
    
    // MARK: - Method
    
    func open(
        webSocketAPI: WebSocketable,
        completionHandler: @escaping CompletionHandler
    ) {
        guard (webSocketAPI.url) != nil else {
            completionHandler(.failure(WebSocketError.urlIsNil))
            return
        }
        
        webSocketTask?.resume()
        send(to: webSocketAPI.message, completionHandler: completionHandler)
        receive(with: completionHandler)
    }
    
    func close() {
        webSocketTask?.cancel()
    }
    
    // MARK: - Private Method
    
    private func send(
        to message: Data,
        completionHandler: @escaping CompletionHandler
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
        with completionHandler: @escaping CompletionHandler
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
