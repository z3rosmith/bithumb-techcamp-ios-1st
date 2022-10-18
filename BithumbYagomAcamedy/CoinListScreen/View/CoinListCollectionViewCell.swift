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

fileprivate let timeAnimationInterval: TimeInterval = 0.5

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
        
        let changeRate = item.changeRate
        
        if changeRate == 0 {
            changeLabelColor(.label)
        } else if changeRate > 0 {
            changeLabelColor(.systemRed)
        } else {
            changeLabelColor(.systemBlue)
        }
    }
    
    func updateAndAnimate(from newItem: ViewCoin) {
        priceLabel.text = newItem.priceString
        changeRateLabel.text = newItem.changeRateString
        changePriceLabel.text = newItem.changePriceString
        
        animateUnderlineView(from: newItem)
    }
    
    private func animateUnderlineView(from newItem: ViewCoin) {
        switch newItem.changePriceStyle {
        case .up:
            addTimerUnderlineViewAnimation(with: .systemRed)
        case .down:
            addTimerUnderlineViewAnimation(with: .systemBlue)
        default:
            break
        }
    }
    
    private func changeLabelColor(_ color: UIColor) {
        priceLabel.textColor = color
        changePriceLabel.textColor = color
        changeRateLabel.textColor = color
    }
    
    private func addTimerUnderlineViewAnimation(with underlineViewColor: UIColor) {
        underlineView.backgroundColor = underlineViewColor
        underlineView.isHidden = false
        let timer = Timer.scheduledTimer(withTimeInterval: timeAnimationInterval, repeats: false) { [weak self] _ in
            self?.underlineView.isHidden = true
        }
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    private func configure() {
        underlineView.isHidden = true
    }
}

final class ViewDisplaySelector {
    static let shared = ViewDisplaySelector()
    
    /// index에 따라 저장된 시간
    private var latestAddedTime: [Int: Date] = [:]
    private let serialQueue = DispatchQueue(label: "TimeAnimationQueue")
    
    private init() { }
    
    func canDisplay(index: Int, in timeInterval: TimeInterval = timeAnimationInterval) -> Bool {
        return serialQueue.sync {
            if let date = latestAddedTime[index], abs(date.distance(to: Date())) < timeInterval {
                return false
            } else {
                latestAddedTime[index] = Date()
                return true
            }
        }
    }
}
