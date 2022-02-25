//
//  AssetsStatusAllValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct AssetsStatusValueObject: Decodable {
    let status: String
    let assetstatus: [String: AssetStatusData]
    
    enum CodingKeys: String, CodingKey {
        case status
        case assetstatus = "data"
    }
}

struct AssetStatusData: Decodable {
    let withdrawalStatus: Int
    let depositStatus: Int
}
