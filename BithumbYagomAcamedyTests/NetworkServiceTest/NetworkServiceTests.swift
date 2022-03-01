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
    var networkService: HTTPNetworkService?
    var mockAPI: MockAPI?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        networkService = HTTPNetworkService()
        mockAPI = MockAPI(url: URL(string: "www"), method: .get)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        networkService = nil
        mockAPI = nil
    }
    
    func test_URL이_유효하지않을때_Error가_나오는지() {
        guard let mockAPI = mockAPI else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
            
        networkService?.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
    
    func test_URL이_Nil일때_invalidURLRequest에러가_나오는지() {
        let mockAPI = MockAPI()
        
        networkService?.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .invalidURLRequest)
            }
        }
    }
    
    func test_MockURLSession의_isSuccess가_true일때_정상동작_하는지() {
        guard let mockAPI = mockAPI else {
            XCTFail()
            return
        }
        
        let mockSession = MockURLSession(isSuccess: true)
        networkService = HTTPNetworkService(session: mockSession)
        
        networkService?.request(api: mockAPI) { result in
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
        guard let mockAPI = mockAPI else {
            XCTFail()
            return
        }
        
        let mockSession = MockURLSession(isSuccess: false)
        networkService = HTTPNetworkService(session: mockSession)
        
        networkService?.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .statusCodeError(400))
            }
        }
    }
    
    func test_MockURLSession의_MockError을_담아보냈을때_MockError을_반환하는지() {
        guard let mockAPI = mockAPI else {
            XCTFail()
            return
        }
        
        let mockSession = MockURLSession(isSuccess: false, error: .mockError)
        networkService = HTTPNetworkService(session: mockSession)
        
        networkService?.request(api: mockAPI) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .unknown(error: MockNetworkError.mockError))
            }
        }
    }
}
