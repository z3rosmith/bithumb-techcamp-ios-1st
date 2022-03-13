//
//  JSONParser.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import Foundation

enum JSONParserError: Error {
    case notConvertedString
}

struct JSONParser {
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(type, from: data)
    }
    
    func decode<T: Decodable>(string: String, type: T.Type) throws -> T {
        guard let data = string.data(using: .utf8) else {
            throw JSONParserError.notConvertedString
        }
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(type, from: data)
    }
                    
    func decode(data: Data) throws -> [String: Any]? {
        let data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        return data
    }
}

extension JSONParser {
    func parse<T: Decodable>(
        to data: Data,
        type: T.Type
    ) throws -> T {
        do {
            let valueObjcet = try JSONParser().decode(
                data: data,
                type: T.self
            )
            
            return valueObjcet
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
}


