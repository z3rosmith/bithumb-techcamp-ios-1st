//
//  JSONParserTests.swift
//  BithumbYagomAcamedyTests
//
//  Created by Oh Donggeon on 2022/02/24.
//

import XCTest
@testable import BithumbYagomAcamedy

class JSONParserTests: XCTestCase {
    private var parser: JSONParser?
    private let successCode = "0000"
    
    override func setUpWithError() throws {
        parser = JSONParser()
    }
    
    override func tearDownWithError() throws {
        parser = nil
    }
    
    func test_ticker_json_파일을_디코딩_시_ticker_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "TickerJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let value = try XCTUnwrap(parser?.decode(data: data, type: TickerValueObject.self))
        
        XCTAssertEqual(value.status, successCode)
        XCTAssertEqual(value.ticker.date, "1645762009832")
    }
    
    func test_tickers_json_파일을_디코딩_시_tickers_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "TickersJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let value = try XCTUnwrap(parser?.decode(data: data, type: TickersValueObject.self))
        
        XCTAssertEqual(value.status, successCode)
        XCTAssertEqual(value.ticker["date"]?.dateString, "1645677730995")
    }
    
    func test_orderbook_json_파일을_디코딩_시_orderbook_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "OrderbookJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let value = try XCTUnwrap(parser?.decode(data: data, type: OrderbookValueObject.self))
        
        XCTAssertEqual(value.status, successCode)
        XCTAssertEqual(value.orderbook.timestamp, "1645762361060")
    }
    
    func test_transaction_json_파일을_디코딩_시_transaction_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "TransactionJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let value = try XCTUnwrap(parser?.decode(data: data, type: TranscationValueObject.self))
        
        XCTAssertEqual(value.status, successCode)
        XCTAssertEqual(value.transaction[Int.zero].transactionDate, "2022-02-25 13:15:49")
    }
    
    func test_assets_status_json_파일을_디코딩_시_assets_status_all_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "AssetsStatusJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        let value = try XCTUnwrap(parser?.decode(data: data, type: AssetsStatusValueObject.self))
        
        XCTAssertEqual(value.status, successCode)
        XCTAssertEqual(value.assetstatus["BTC"]?.depositStatus, 1)
        XCTAssertEqual(value.assetstatus["BTC"]?.withdrawalStatus, 1)
    }
}
