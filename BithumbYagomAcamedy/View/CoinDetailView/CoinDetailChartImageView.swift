//
//  CoinDetailChartImageView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/07.
//

import UIKit

final class CoinDetailChartImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        drawChart(price: [10, 20, 30, 20, 10, 0, 10])
    }
    
    private func getContext() -> CGContext? {
        UIGraphicsBeginImageContext(layer.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        return context
    }
    
    private func setImage(with context: CGContext) {
        context.closePath()
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func drawChart(price: [Double]) {
        guard let context = getContext() else {
            return
        }
        
        let min = price.min()
        let max = price.max()
        let xUnit = layer.frame.width / CGFloat(price.count)
        let yUnit = layer.frame.height / (max! - min!)
        
        context.setStrokeColor(UIColor.systemRed.cgColor)
        context.move(to: CGPoint(x: 0, y: 0))
        let startPoint = CGPoint(x: CGFloat.zero, y: price[0] * yUnit)
        
        var previousPoint = startPoint
        context.move(to: previousPoint)
        
        for (index, price) in price.enumerated() {
            
            
            let nextPoint = CGPoint(x: xUnit * CGFloat(index), y: yUnit * price)
            
            if previousPoint.y < nextPoint.y {
                context.setStrokeColor(UIColor.systemRed.cgColor)
            } else {
                context.setStrokeColor(UIColor.systemBlue.cgColor)
            }
            context.move(to: previousPoint)
            context.addLine(to: nextPoint)
            print(previousPoint, nextPoint)
            context.strokePath()
            previousPoint = nextPoint
        }
        
        setImage(with: context)
    }
}
