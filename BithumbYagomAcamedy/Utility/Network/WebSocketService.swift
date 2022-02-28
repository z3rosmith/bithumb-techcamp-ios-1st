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
    
    // MARK: - Typealias
    
    typealias CompletionHandler = (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    
    // MARK: - Property
    
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTaskProviding?
    
    // MARK: - Init
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Method
    
    mutating func open(
        webSocketAPI: WebSocketable,
        completionHandler: @escaping CompletionHandler
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
    
    // MARK: - Private Method
    
    private func send(
        to message: Data,
        completionHandler: @escaping CompletionHandler
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
        with completionHandler: @escaping CompletionHandler
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
