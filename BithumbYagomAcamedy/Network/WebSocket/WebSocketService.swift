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
    case sendFailure(error: Error)
    case receiveFailure(error: Error)
    case unknown(error: Error)

    var errorDescription: String? {
        switch self {
        case .urlIsNil:
            return "정상적인 URL이 아닙니다."
        case .emptyWebSocketTransactionData:
            return "Decode 에러 또는 WebSocketTransactionData가 비어있습니다."
        case .messageIsNotString:
            return "message가 String이 아닙니다."
        case .sendFailure(let error):
            return "send중 \(error) 에러가 발생했습니다."
        case .receiveFailure(let error):
            return "receive중 \(error) 에러가 발생했습니다."
        case .unknown(let error):
            return "\(error) 에러가 발생했습니다."
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
                completionHandler(.failure(WebSocketError.sendFailure(error: error)))
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
                case .failure(let error):
                    completionHandler(.failure(WebSocketError.receiveFailure(error: error)))
                }
                self.receive(with: completionHandler)
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
                    print(error)
                    break
                }
            }
            return Disposables.create {
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
            print(string, "을 decode 중 에러가 발생하였습니다")
            print(error)
            throw error
        }
    }
}
