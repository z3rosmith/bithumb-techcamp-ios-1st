//
//  JSONParser.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import Foundation

struct JSONPerser {
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(type, from: data)
    }
    
    func decode(data: Data) throws -> [String: Any]? {
        let data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        return data
    }
}
