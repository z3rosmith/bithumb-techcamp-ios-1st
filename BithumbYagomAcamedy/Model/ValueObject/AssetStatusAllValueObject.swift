//
//  AssetStatusAllValueObject.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/24.
//

import Foundation

struct AssetStatusAllValueObject: Decodable {
    let status: String
    let data: [String: AssetStatusData]
}

struct AssetStatusData: Decodable {
    let withdrawalStatus: Int
    let depositStatus: Int
}
