//
//  URLSessionWebSocketTask+extension.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/28.
//

import Foundation

protocol URLSessionWebSocketTaskProviding {
    func resume()
    func cancel()
    func send(
        _ message: URLSessionWebSocketTask.Message,
        completionHandler: @escaping (Error?) -> Void
    )
    func receive(
        completionHandler: @escaping (
            Result<URLSessionWebSocketTask.Message, Error>
        ) -> Void
    )
}

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProviding { }
