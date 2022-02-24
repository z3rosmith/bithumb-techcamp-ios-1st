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

final class MockURLSession: URLSessionProtocol {
    private let isSuccess: Bool
    
    init(isSuccess: Bool = true) {
        self.isSuccess = isSuccess
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
            sessionDataTask.resumeDidCall = {
                completionHandler(data, successResponse, nil)
            }
        } else {
            sessionDataTask.resumeDidCall = {
                completionHandler(nil, failureResponse, nil)
            }
        }
        
        return sessionDataTask
    }
}
