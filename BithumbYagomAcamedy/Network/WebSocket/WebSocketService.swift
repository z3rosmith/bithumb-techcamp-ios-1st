//
//  WebSocketService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/25.
//

import Foundation
import RxSwift

enum WebSocketError: Error, LocalizedError {
    case urlIsNil
    case emptyWebSocketTransactionData
    case messageIsNotString
    case unknown(error: Error)

    var errorDescription: String? {
        switch self {
        case .urlIsNil:
            return "정상적인 URL이 아닙니다."
        case .emptyWebSocketTransactionData:
            return "WebSocketTransactionData가 비어있습니다."
        case .messageIsNotString:
            return "message가 String이 아닙니다."
        case .unknown(let error):
            return "\(error.localizedDescription) 에러가 발생했습니다."
        }
    }
}

class WebSocketService: WebSocketServicable {
    
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
    
    func open(
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
        print("✅✅", #function)
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
        DispatchQueue.global().async {
            self.webSocketTask?.receive { result in
                switch result {
                case .success(let message):
                    completionHandler(.success(message))
                    self.receive(with: completionHandler)
                case .failure(let error):
                    completionHandler(.failure(WebSocketError.unknown(error: error)))
                }
            }
        }
    }
}

// MARK: - RxSwift Wrapping

extension WebSocketService {
    func openRx(webSocketAPI: WebSocketable) -> Observable<WebSocketTransactionData.WebSocketTransaction> {
        return Observable.create { emitter in
            self.open(webSocketAPI: webSocketAPI) { [weak self] result in
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let response):
                        let transaction = try? self?.parsedWebSocketTranscationValueObject(from: response)
                        guard let transactionFirst = transaction?.webSocketTransactionData.list.first else {
                            print(WebSocketError.emptyWebSocketTransactionData.localizedDescription)
                            return
                        }
                        emitter.onNext(transactionFirst)
                    default:
                        print(WebSocketError.messageIsNotString.localizedDescription)
                        break
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
            return Disposables.create {
                print("✅✅ Disposable create handler")
                self.close()
            }
        }
    }
    
    private func parsedWebSocketTranscationValueObject(
        from string: String
    ) throws -> WebSocketTransactionValueObject {
        do {
            let webSocketTransactionValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketTransactionValueObject.self
            )
            return webSocketTransactionValueObject
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
