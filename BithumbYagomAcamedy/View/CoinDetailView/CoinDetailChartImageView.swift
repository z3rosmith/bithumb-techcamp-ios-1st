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
    
    private func drawPath(
        from previousPoint: CGPoint,
        to nextPoint: CGPoint,
        with context: CGContext
    ) {
        context.move(to: previousPoint)
        context.addLine(to: nextPoint)
        context.strokePath()
    }
    
    private func setPathColor(
        from previousPoint: CGPoint,
        to nextPoint: CGPoint,
        with context: CGContext
    ) {
        if previousPoint.y < nextPoint.y {
            context.setStrokeColor(UIColor.systemBlue.cgColor)
        } else {
            context.setStrokeColor(UIColor.systemRed.cgColor)
        }
    }
    
    private func setAxisUnit(price: [Double]) -> (x: CGFloat, y: CGFloat) {
        guard let min = price.min(),
              let max = price.max()
        else {
            return (CGFloat.zero, CGFloat.zero)
        }
        
        let xUnit = layer.frame.width / CGFloat(price.count)
        let yUnit = layer.frame.height / (max - min)
        
        return (xUnit, yUnit)
    }
    
    func drawChart(price: [Double]) {
        guard let context = getContext() else {
            return
        }
        
        let axisUnit = setAxisUnit(price: price)
        let startPoint = CGPoint(
            x: CGFloat.zero,
            y: frame.height - (price[0] * axisUnit.y)
        )
        var previousPoint = startPoint
        context.move(to: previousPoint)
        
        for (index, price) in price.enumerated() {
            let nextPoint = CGPoint(
                x: axisUnit.x * CGFloat(index),
                y: frame.height - (axisUnit.y * price)
            )
            
            setPathColor(from: previousPoint, to: nextPoint, with: context)
            drawPath(from: previousPoint, to: nextPoint, with: context)
            
            previousPoint = nextPoint
        }
        
        setImage(with: context)
    }
}
