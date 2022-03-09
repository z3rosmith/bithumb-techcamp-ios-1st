//
//  DepositWithdrawalCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/25.
//

import UIKit

protocol DepositWithdrawalCellDataProviding {
    var coinName: String { get }
    var coinSymbol: String { get }
    var depositStatus: String { get }
    var withdrawalStatus: String { get }
    var isValidDeposit: Bool { get }
    var isValidWithdrawal: Bool { get }
}

final class DepositWithdrawalCollectionViewCell: UICollectionViewListCell {
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var coinSymbolAndCurrencyLabel: UILabel!
    @IBOutlet private weak var depositStatusView: UIView!
    @IBOutlet private weak var withdrawalStatusView: UIView!
    @IBOutlet private weak var depositStatusLabel: UILabel!
    @IBOutlet private weak var withdrawalStatusLabel: UILabel!
    
    private let successStatusColorName = "SuccessStatus"
    private let failStatusColorName = "FailStatus"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        depositStatusView.layer.cornerRadius = depositStatusView.frame.width / 2
        withdrawalStatusView.layer.cornerRadius = withdrawalStatusView.frame.width / 2
    }
    
    func update(_ value: DepositWithdrawalCellDataProviding) {
        coinNameLabel.text = value.coinName
        coinSymbolAndCurrencyLabel.text = value.coinSymbol
        depositStatusLabel.text = value.depositStatus
        withdrawalStatusLabel.text = value.withdrawalStatus
        depositStatusView.backgroundColor = statusColor(from: value.isValidDeposit)
        withdrawalStatusView.backgroundColor = statusColor(from: value.isValidWithdrawal)
    }
    
    private func statusColor(from status: Bool) -> UIColor? {
        return status ? UIColor(named: successStatusColorName) : UIColor(named: failStatusColorName)
    }
}
