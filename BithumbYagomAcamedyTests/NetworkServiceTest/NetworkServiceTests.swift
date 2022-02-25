//
//  NetworkServiceTests.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/24.
//

import XCTest
@testable import BithumbYagomAcamedy

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription
    }
}

struct MockAPI: Gettable {
    var url: URL?
    var method: HTTPMethod = .get
}

class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var mockAPI: MockAPI!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        networkService = NetworkService()
        mockAPI = MockAPI(url: URL(string: "www"), method: .get)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        networkService = nil
        mockAPI = nil
    }
    
    func test_URL이_유효하지않을때_statusCodeError가_나오는지() {
        networkService.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .statusCodeError)
            }
        }
    }
    
    func test_URL이_Nil일때_invalidURLRequest에러가_나오는지() {
        mockAPI = MockAPI()
        
        networkService.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .invalidURLRequest)
            }
        }
    }
    
    func test_MockURLSession의_isSuccess가_true일때_정상동작_하는지() {
        let mockSession = MockURLSession(isSuccess: true)
        networkService = NetworkService(session: mockSession)
        
        networkService.request(api: mockAPI) { result in
            switch result {
            case .success(let data):
                let resultString = String(data: data, encoding: .utf8)
                let successString = #""OK""#
                XCTAssertEqual(resultString, successString)
            case .failure(_):
                XCTFail()
            }
        }
    }
    
    func test_MockURLSession의_isSuccess가_false일때_실패하는지() {
        let mockSession = MockURLSession(isSuccess: false)
        networkService = NetworkService(session: mockSession)
        
        networkService.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .statusCodeError)
            }
        }
    }
    
    func test_MockURLSession의_MockError을_담아보냈을때_MockError을_반환하는지() {
        let mockSession = MockURLSession(isSuccess: false, error: .mockError)
        networkService = NetworkService(session: mockSession)
        
        networkService.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .unknown(error: MockNetworkError.mockError))
            }
        }
    }
}
