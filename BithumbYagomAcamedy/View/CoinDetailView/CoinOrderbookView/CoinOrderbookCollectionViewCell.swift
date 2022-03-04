//
//  CoinOrderbookCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import UIKit

final class CoinOrderbookCollectionViewCell: UICollectionViewListCell {
    
    // MARK: - Static Property
    static let identifier = "CoinOrderbookCollectionViewCell"
    
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var askQuantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bidQuantityLabel: UILabel!
    
}
