//
//  CoinListCollectionViewCell.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/24.
//

import UIKit

protocol CoinListCollectionViewCellDelegate: AnyObject {
    func coinListCollectionViewCellDelegate(didUserSwipe cell: UICollectionViewListCell, isSwiped: Bool)
}

final class CoinListCollectionViewCell: UICollectionViewListCell {

    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var symbolPerCurrencyLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var changeRateLabel: UILabel!
    @IBOutlet private weak var changePriceLabel: UILabel!
    @IBOutlet private weak var underlineView: UIView!
    
    static let identifier = "CoinListCollectionViewCell"
    
    var toggleFavorite: (() -> Void)?
    weak var delegate: CoinListCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        delegate?.coinListCollectionViewCellDelegate(didUserSwipe: self, isSwiped: state.isSwiped)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        toggleFavorite?()
    }
    
    func update(from item: ViewCoin) {
        favoriteButton.isSelected = item.isFavorite
        nameLabel.text = item.callingName
        symbolPerCurrencyLabel.text = item.symbolPerKRW
        priceLabel.text = item.priceString
        changeRateLabel.text = item.changeRateString
        changePriceLabel.text = item.changePriceString
    }
    
//    func update(item: Coin) {
//        favoriteButton.isSelected = item.isFavorite
//        nameLabel.text = item.callingName
//        symbolPerCurrencyLabel.text = item.symbolPerKRW
//        priceLabel.text = item.priceString
//        changeRateLabel.text = item.changeRateString
//        changePriceLabel.text = item.changePriceString
//
//        guard let changeRate = item.changeRate else { return }
//
//        if changeRate == 0 {
//            changeLabelColor(.label)
//        } else if changeRate > 0 {
//            changeLabelColor(.systemRed)
//        } else {
//            changeLabelColor(.systemBlue)
//        }
//    }
    
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
