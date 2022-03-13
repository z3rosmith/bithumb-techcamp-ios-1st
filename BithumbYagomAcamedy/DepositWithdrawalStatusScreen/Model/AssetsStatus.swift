//
//  AssetsStatus.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/28.
//

import Foundation

struct AssetsStatus: DepositWithdrawalCellDataProviding, Hashable {
    private(set) var coinName: String
    private(set) var coinSymbol: String
    private(set) var depositStatus: String
    private(set) var withdrawalStatus: String
    private(set) var isValidDeposit: Bool
    private(set) var isValidWithdrawal: Bool
    private let uuid: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    static func ==(lhs: AssetsStatus, rhs: AssetsStatus) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    init(coinSymbol: String, assetStatusData: AssetStatusData) {
        self.coinName = NSLocalizedString(coinSymbol, comment: "")
        self.coinSymbol = coinSymbol
        self.isValidDeposit = assetStatusData.depositStatus == Int.zero ? false : true
        self.isValidWithdrawal = assetStatusData.withdrawalStatus == Int.zero ? false : true
        self.depositStatus = assetStatusData.depositStatus == Int.zero ? "중단" :"정상"
        self.withdrawalStatus = assetStatusData.withdrawalStatus == Int.zero ? "중단" : "정상"
    }
}
