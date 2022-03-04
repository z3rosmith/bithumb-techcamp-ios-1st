//
//  CoinDetailMenuStackView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/03.
//

import UIKit

final class CoinDetailMenuStackView: UIStackView {
    
    // MARK: - Property
    
    private lazy var underLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.label.cgColor
        
        guard let firstButtonFrame = subviews.first?.frame else {
            return layer
        }
        
        layer.frame = CGRect(
            x: firstButtonFrame.origin.x + 15,
            y: firstButtonFrame.height,
            width: firstButtonFrame.width - 30,
            height: 4
        )
        
        return layer
    }()
    
    private lazy var currentUnderLinePoint: CGPoint = {
        let point = CGPoint(
            x: underLineLayer.frame.origin.x + underLineLayer.frame.width / 2,
            y: underLineLayer.frame.origin.y + underLineLayer.frame.height / 2
        )
        
        return point
    }()
    
    private let underLineAnimation = CABasicAnimation(keyPath: "position")
    
    // MARK: - Configure
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUnderLine()
    }
    
    private func configureUnderLine() {
        layer.addSublayer(underLineLayer)
    }
        
    @objc private func moveUnderLine(_ sender: UIButton) {
        
    }
    
    // MARK: - Method
    
    func moveUnderLine(index: Int) {
        let destinationX = subviews[index].frame.origin.x + subviews[index].frame.width / 2
        
        underLineAnimation.fromValue = [
            currentUnderLinePoint.x,
            currentUnderLinePoint.y,
        ]
        underLineAnimation.toValue = [
            destinationX,
            currentUnderLinePoint.y
        ]
        underLineAnimation.duration = 0.2
        underLineAnimation.fillMode = .forwards
        underLineAnimation.isRemovedOnCompletion = false
        
        currentUnderLinePoint.x = destinationX
        
        underLineLayer.add(underLineAnimation, forKey: nil)
    }
}
