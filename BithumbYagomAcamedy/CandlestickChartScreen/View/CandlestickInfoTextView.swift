//
//  CandlestickInfoTextView.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import UIKit

final class CandlestickInfoTextView: UITextView {
    func update(price: CandlestickPrice) {
        let priceColor: UIColor
        
        if price.isIncreasePrice {
            priceColor = .red
        } else if price.isDecreasePrice {
            priceColor = .blue
        } else {
            priceColor = .label
        }
        
        attributedText = updatePriceTextColor(to: priceColor, candlestickPrice: price)
    }
    
    private func updatePriceTextColor(
        to color: UIColor, candlestickPrice: CandlestickPrice
    ) -> NSMutableAttributedString {
        let priceInformation = candlestickPrice.priceInformation
        let attributedString = NSMutableAttributedString(string: priceInformation)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.label,
            range: (priceInformation as NSString).range(of: priceInformation)
        )
        
        candlestickPrice.pricesString.forEach { priceString in
            attributedString.addAttribute(
                .foregroundColor,
                value: color,
                range: (priceInformation as NSString).range(of: "\(priceString)")
            )
        }
        
        return attributedString
    }
}
