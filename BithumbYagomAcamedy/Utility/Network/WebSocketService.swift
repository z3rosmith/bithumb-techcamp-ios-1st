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
            return "정상적인 URL이 아닙니다."
        case .unknown(let error):
            return "\(error.localizedDescription) 에러가 발생했습니다."
        }
    }
}

struct WebSocketService: WebSocketServicable {
    typealias completionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTaskProviding?
    
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
        
        webSocketTask = session.webSocketTask(with: url)
        
        webSocketTask?.resume()
        send(to: webSocketAPI.message, completionHandler: completionHandler)
        receive(with: completionHandler)
    }
    
    func close() {
        webSocketTask?.cancel()
    }
    
    private func send(
        to message: Data,
        completionHandler: @escaping completionHandler
    ) {
        webSocketTask?.send(
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
            self.webSocketTask?.receive { result in
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
