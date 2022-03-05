//
//  CoinDetailPriceView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import UIKit

final class CoinDetailPriceView: UIView {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var changePriceLabel: UILabel!
    @IBOutlet private weak var changeRateLabel: UILabel!
        
    // MARK: - Method
    
    func update(_ coin: DetailViewCoin) {
        guard let changeRate = coin.changeRate else {
            return
        }
        
        if changeRate == 0 {
            changeLabelColor(.label)
        } else if changeRate > 0 {
            changeLabelColor(.systemRed)
        } else {
            changeLabelColor(.systemBlue)
        }
        
        priceLabel.text = coin.commaPrice
        changePriceLabel.text = coin.changePriceString
        changeRateLabel.text = coin.changeRateString
    }
    
    private func changeLabelColor(_ color: UIColor) {
        priceLabel.textColor = color
        changePriceLabel.textColor = color
        changeRateLabel.textColor = color
    }
}
