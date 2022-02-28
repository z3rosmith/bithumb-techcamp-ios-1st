//
//  WebSocketServiceTests.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/28.
//

import XCTest
@testable import BithumbYagomAcamedy

// MARK: - Extension

extension WebSocketError: Equatable {
    public static func == (lhs: WebSocketError, rhs: WebSocketError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription
    }
}

// MARK: - Mock

struct MockWebSocketAPI: WebSocketable {
    var url: URL?
    var message = ("OK".data(using: .utf8))!
}

class WebSocketServiceTests: XCTestCase {
    
    // MARK: - Property
    
    var webSocketService: WebSocketServicable!
    var mockWebSocketAPI: MockWebSocketAPI!
    
    // MARK: - Method
    
    override func setUpWithError() throws {
        mockWebSocketAPI = MockWebSocketAPI(url: URL(string: "www"))
    }

    override func tearDownWithError() throws {
        webSocketService = nil
        mockWebSocketAPI = nil
    }

    // MARK: - Production Code Tests
    
    func test_URL이_유효하지않을때_Error가_나오는지() {
        webSocketService = WebSocketService()
        mockWebSocketAPI = MockWebSocketAPI()
        
        webSocketService.open(webSocketAPI: mockWebSocketAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error as! WebSocketError, WebSocketError.urlIsNil)
            }
        }
    }
    
    func test_데이터를_잘_받아오는지() throws {
        let url = URL(string: "wss://pubwss.bithumb.com/pub/ws")
        let testSendJSONurl = try XCTUnwrap(Bundle(for: type(of: self))
                                            .url(forResource: "WebSocketSendJSON", withExtension: "json"))
        let testSendJSONdata = try XCTUnwrap(Data(contentsOf: testSendJSONurl))
        let testReceivedString = #"{"status":"0000","resmsg":"Connected Successfully"}"#
        webSocketService = WebSocketService()
        mockWebSocketAPI = MockWebSocketAPI(url: url, message: testSendJSONdata)
        let expectation = XCTestExpectation()
        
        webSocketService.open(webSocketAPI: mockWebSocketAPI) { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let result):
                    XCTAssertEqual(result, testReceivedString)
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            case .failure(_):
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 3)
    }
    
    // MARK: - MockObject Tests
    
    func test_WebSocketService_send메서드에_error가_발생하는지() {
        let webSocketTask = MockWebSocketURLSessionTask(isSuccess: false)
        webSocketService = MockWebSocketService(webSocketTask: webSocketTask)
        
        webSocketService.open(webSocketAPI: mockWebSocketAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(
                    error as! WebSocketError,
                    WebSocketError.unknown(error: MockNetworkError.mockError)
                )
            }
        }
    }
    
    func test_WebSocketService_메세지_송수신이되는지() {
        let webSocketTask = MockWebSocketURLSessionTask(isSuccess: true)
        webSocketService = MockWebSocketService(webSocketTask: webSocketTask)
        
        webSocketService.open(webSocketAPI: mockWebSocketAPI) { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    XCTAssertEqual(data, self.mockWebSocketAPI.message)
                default:
                    XCTFail()
                }
            case .failure(_):
                XCTFail()
            }
        }
    }
}
