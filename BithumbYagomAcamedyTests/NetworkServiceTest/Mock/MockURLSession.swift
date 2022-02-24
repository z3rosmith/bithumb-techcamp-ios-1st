//
//  MockURLSession.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation
@testable import BithumbYagomAcamedy

final class MockURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall()
    }
}

enum MockNetworkError: Error {
    case mockError
}

final class MockURLSession: URLSessionProtocol {
    private let isSuccess: Bool
    private let error: MockNetworkError?
    
    init(isSuccess: Bool = true, error: MockNetworkError? = nil) {
        self.isSuccess = isSuccess
        self.error = error
    }
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        guard let url = request.url else {
            return URLSessionDataTask()
        }
        
        let successResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: nil
        )
        let failureResponse = HTTPURLResponse(
            url: url,
            statusCode: 400,
            httpVersion: "1.1",
            headerFields: nil
        )
        
        let dataString = #""OK""#
        let data = dataString.data(using: .utf8)
        let sessionDataTask = MockURLSessionDataTask()
        
        if isSuccess {
            sessionDataTask.resumeDidCall = { [weak self] in
                completionHandler(data, successResponse, self?.error)
            }
        } else {
            sessionDataTask.resumeDidCall = { [weak self] in
                completionHandler(nil, failureResponse, self?.error)
            }
        }
        
        return sessionDataTask
    }
}
