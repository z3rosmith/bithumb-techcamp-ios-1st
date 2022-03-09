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
    
    @IBOutlet private weak var askQuantityBackgroundView: UIView!
    @IBOutlet private weak var priceBackgroundView: UIView!
    @IBOutlet private weak var bidQuantityBackgroundView: UIView!
    @IBOutlet private weak var askQuantityLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var bidQuantityLabel: UILabel!
    
    // MARK: - Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLabel()
    }
    
    func configureLabel() {
        priceLabel.text = String()
        askQuantityLabel.text = String()
        bidQuantityLabel.text = String()
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.text = String()
        askQuantityLabel.text = String()
        bidQuantityLabel.text = String()
    }
    
    func update(_ item: Orderbook) {
        priceLabel.text = item.commaPrice
        updateQuantityLabel(item)
        updateLabelsTextColor(item.type)
        updateLabelsBackgroundColor(item.type)
    }
    
    private func updateQuantityLabel(_ item: Orderbook) {
        if item.type == .ask {
            askQuantityLabel.text = item.roundedQuantity
        } else {
            bidQuantityLabel.text = item.roundedQuantity
        }
    }
    
    private func updateLabelsTextColor(_ type: OrderbookType) {
        priceLabel.textColor = labelColor(type: type)
        askQuantityLabel.textColor = labelColor(type: type)
        bidQuantityLabel.textColor = labelColor(type: type)
    }
    
    private func updateLabelsBackgroundColor(_ type: OrderbookType) {
        priceBackgroundView.backgroundColor = labelBackgroundColor(type: type)
        if type == .ask {
            askQuantityBackgroundView.backgroundColor = labelBackgroundColor(type: type)
            bidQuantityBackgroundView.backgroundColor = .systemBackground
        } else {
            askQuantityBackgroundView.backgroundColor = .systemBackground
            bidQuantityBackgroundView.backgroundColor = labelBackgroundColor(type: type)
        }
    }
    
    private func labelColor(type: OrderbookType) -> UIColor {
        return type == .bid ? UIColor.systemRed : UIColor.systemBlue
    }
    
    private func labelBackgroundColor(type: OrderbookType) -> UIColor? {
        return type == .bid ? UIColor(named: "Bid") : UIColor(named: "Ask")
    }
}
