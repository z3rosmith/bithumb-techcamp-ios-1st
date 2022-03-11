//
//  MaximunMinimunOrderPriceView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/11.
//

import UIKit

final class MaximunMinimunOrderPriceView: UIView {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    
    // MARK: - Method
    
    func update(_ item: Orderbook) {
        priceLabel.text = item.commaPrice
        quantityLabel.text = item.roundedQuantity
    }
}
