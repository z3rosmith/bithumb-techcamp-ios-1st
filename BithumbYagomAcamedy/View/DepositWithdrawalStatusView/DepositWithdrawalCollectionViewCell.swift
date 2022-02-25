//
//  DepositWithdrawalCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/25.
//

import UIKit

final class DepositWithdrawalCollectionViewCell: UICollectionViewListCell {
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var coinSymbolAndCurrencyLabel: UILabel!
    @IBOutlet private weak var depositStatusView: UIView!
    @IBOutlet private weak var withdrawalStatusView: UIView!
    @IBOutlet private weak var depositStatusLabel: UILabel!
    @IBOutlet private weak var withdrawalStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        depositStatusView.layer.cornerRadius = depositStatusView.frame.width / 2
        withdrawalStatusView.layer.cornerRadius = withdrawalStatusView.frame.width / 2
    }
    
    func update(_ data: DepositWithdrawalStatusViewController.MockData) {
        coinNameLabel.text = data.name
        coinSymbolAndCurrencyLabel.text = data.symbol
        depositStatusView.backgroundColor = statusColor(from: data.depositStatus)
        withdrawalStatusView.backgroundColor = statusColor(from: data.withdrawalStatus)
    }
    
    private func statusColor(from status: Bool) -> UIColor {
        return status ? .blue : .red
    }
}
