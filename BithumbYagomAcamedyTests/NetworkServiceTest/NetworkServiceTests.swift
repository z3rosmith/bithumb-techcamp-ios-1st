//
//  NetworkServiceTests.swift
//  BithumbYagomAcamedyTests
//
//  Created by 황제하 on 2022/02/24.
//

import XCTest
@testable import BithumbYagomAcamedy

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
}
