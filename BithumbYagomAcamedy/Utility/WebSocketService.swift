//
//  WebSocketService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/25.
//

import Foundation

class WebSocketService {
    typealias completionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    private let session: URLSession
    private var websocketTask: URLSessionWebSocketTask?
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func open(
        url: URL,
        with message: Data,
        completionHandler: @escaping completionHandler
    ) {
        websocketTask = session.webSocketTask(with: url)
        
        websocketTask?.resume()
        websocketTask?.send(
            .data(message)
        ) { error in
            if let error = error {
                completionHandler(.failure(error))
            }
        }
        receiveMessage(with: completionHandler)
    }
    
    func close() {
        websocketTask?.cancel()
    }
    
    func receiveMessage(
        with completionHandler: @escaping completionHandler
    ) {
        DispatchQueue.global().async { [weak self] in
            self?.websocketTask?.receive { result in
                switch result {
                case .success(let message):
                    completionHandler(.success(message))
                    self?.receiveMessage(with: completionHandler)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
