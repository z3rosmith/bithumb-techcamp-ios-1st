//
//  CoinDetailTitleButton.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import UIKit

final class CoinDetailTitleButton: UIButton {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTitleLabel()
    }
    
    // MARK: - Method
    
    func configureAttributedTitle(coin: Coin?) {
        guard let coin = coin else {
            return
        }
        
        let attributedTitle = NSMutableAttributedString()
            .setTextSize(string: coin.callingName, fontSize: .title2)
            .setTextColor(string: "\n\(coin.symbolPerKRW)", color: .systemGray)
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func configureTitleLabel() {
        setTitleColor(.label, for: .normal)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
    
    private func configureImage() {
        setImage(UIImage(systemName: "chevron.down"), for: .normal)
        imageView?.tintColor = .label
    }
}

// MARK: - NSMutableAttributedString Extension

private extension NSMutableAttributedString {
    func setTextSize(
        string: String,
        fontSize: UIFont.TextStyle
    ) -> Self {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: fontSize)]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func setTextColor(
        string: String,
        color: UIColor
    ) -> Self {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
}
