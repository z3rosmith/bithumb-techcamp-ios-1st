//
//  MockWebSocketURLSession.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation
@testable import BithumbYagomAcamedy

final class MockWebSocketURLSessionTask: URLSessionWebSocketTaskProviding {
    
    // MARK: - Property
    
    private let isSuccess: Bool
    private let taskError: MockNetworkError
    private(set) var message: URLSessionWebSocketTask.Message?
    
    // MARK: - Init
    
    init(isSuccess: Bool = true, error: MockNetworkError = .mockError) {
        self.isSuccess = isSuccess
        self.taskError = error
    }
    
    // MARK: - Method
    
    func resume() {
        print(#function)
    }
    
    func cancel() {
        print(#function)
    }
    
    func send(
        _ message: URLSessionWebSocketTask.Message,
        completionHandler: @escaping (Error?) -> Void
    ) {
        if isSuccess {
            self.message = message
        } else {
            completionHandler(taskError)
        }
    }
    
    func receive(
        completionHandler: @escaping (
            Result<URLSessionWebSocketTask.Message, Error>
        ) -> Void
    ) {
        if isSuccess, let message = message {
            completionHandler(.success(message))
        } else {
            completionHandler(.failure(taskError))
        }
    }
}
