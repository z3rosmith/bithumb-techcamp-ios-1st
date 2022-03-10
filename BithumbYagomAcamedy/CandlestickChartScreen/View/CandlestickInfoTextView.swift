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
        let priceString = candlestickPrice.priceString
        let attributedString = NSMutableAttributedString(string: priceString)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.label,
            range: (priceString as NSString).range(of: priceString)
        )
        
        candlestickPrice.prices.forEach { price in
            attributedString.addAttribute(
                .foregroundColor,
                value: color,
                range: (priceString as NSString).range(of: "\(price)")
            )
        }
        
        return attributedString
    }
}
