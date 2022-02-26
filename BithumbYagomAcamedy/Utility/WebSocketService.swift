//
//  WebSocketService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/25.
//

import Foundation

enum WebSocketError: LocalizedError {
    case urlIsNil
    case unknown(error: Error)

    var errorDescription: String? {
        switch self {
        case .urlIsNil:
            return "정상적인 URLRequest가 아닙니다."
        case .unknown(let error):
            return "\(error.localizedDescription) 에러가 발생했습니다."
        }
    }
}

struct WebSocketService {
    typealias completionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    private let session: URLSession
    private var websocketTask: URLSessionWebSocketTask?
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    mutating func open(
        webSocketAPI: WebSocketable,
        completionHandler: @escaping completionHandler
    ) {
        guard let url = webSocketAPI.url else {
            completionHandler(.failure(WebSocketError.urlIsNil))
            return
        }
        
        websocketTask = session.webSocketTask(with: url)
        
        websocketTask?.resume()
        send(to: webSocketAPI.message, completionHandler: completionHandler)
        receive(with: completionHandler)
    }
    
    func close() {
        websocketTask?.cancel()
    }
    
    private func send(
        to message: Data,
        completionHandler: @escaping completionHandler
    ) {
        websocketTask?.send(
            .data(message)
        ) { error in
            if let error = error {
                completionHandler(.failure(error))
            }
        }
    }
    
    private func receive(
        with completionHandler: @escaping completionHandler
    ) {
        DispatchQueue.global().async {
            self.websocketTask?.receive { result in
                switch result {
                case .success(let message):
                    completionHandler(.success(message))
                    self.receive(with: completionHandler)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
