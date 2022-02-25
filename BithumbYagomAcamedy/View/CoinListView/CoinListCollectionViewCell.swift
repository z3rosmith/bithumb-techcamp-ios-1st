//
//  CoinListCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import UIKit

class CoinListCollectionViewCell: UICollectionViewListCell {

    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var symbolPerCurrencyLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var changeRateLabel: UILabel!
    @IBOutlet weak private var changePriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(item: CoinListDataSource.Coin) {
        nameLabel.text = item.callingName
        symbolPerCurrencyLabel.text = item.symbolPerKRW
        priceLabel.text = item.priceString
        changeRateLabel.text = item.changeRateString
        changePriceLabel.text = item.changePriceString
    }
}
