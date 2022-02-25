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
        
        XCTAssertNoThrow(try parser?.decode(data: data, type: TickerValueObject.self))
    }
    
    func test_tickers_json_파일을_디코딩_시_tickers_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "TickersJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        
        XCTAssertNoThrow(try parser?.decode(data: data, type: TickersValueObject.self))
    }
    
    func test_orderbook_json_파일을_디코딩_시_orderbook_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "OrderbookJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        
        XCTAssertNoThrow(try parser?.decode(data: data, type: OrderbookValueObject.self))
    }
    
    func test_transaction_json_파일을_디코딩_시_transaction_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "TransactionJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        
        XCTAssertNoThrow(try parser?.decode(data: data, type: TranscationValueObject.self))
    }
    
    func test_assets_status_json_파일을_디코딩_시_assets_status_all_value_object_타입의_인스턴스_반환() throws {
        let url = try XCTUnwrap(Bundle(for: type(of: self))
                                    .url(forResource: "AssetsStatusJSONFile", withExtension: "json"))
        let data = try XCTUnwrap(Data(contentsOf: url))
        
        XCTAssertNoThrow(try parser?.decode(data: data, type: AssetsStatusValueObject.self))
    }
}
