//
//  CoinListCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import UIKit

final class CoinListCollectionViewCell: UICollectionViewListCell {

    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var symbolPerCurrencyLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var changeRateLabel: UILabel!
    @IBOutlet private weak var changePriceLabel: UILabel!
    @IBOutlet private weak var underlineView: UIView!
    
    var toggleFavorite: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        toggleFavorite?()
    }
    
    func update(item: Coin) {
        favoriteButton.isSelected = item.isFavorite
        nameLabel.text = item.callingName
        symbolPerCurrencyLabel.text = item.symbolPerKRW
        priceLabel.text = item.priceString
        changeRateLabel.text = item.changeRateString
        changePriceLabel.text = item.changePriceString
        
        guard let changeRate = item.changeRate else { return }
        
        if changeRate == 0 {
            changeLabelColor(.label)
        } else if changeRate > 0 {
            changeLabelColor(.systemRed)
        } else {
            changeLabelColor(.systemBlue)
        }
    }
    
    private func changeLabelColor(_ color: UIColor) {
        priceLabel.textColor = color
        changePriceLabel.textColor = color
        changeRateLabel.textColor = color
        underlineView.backgroundColor = color
        underlineView.isHidden = false
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.underlineView.isHidden = true
        }
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    private func configure() {
        underlineView.isHidden = true
    }
}
