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
        
        layer.frame = .init(
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
    
    // MARK: - Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUnderLine()
        configureMenuButtons()
    }
    
    private func configureUnderLine() {
        layer.addSublayer(underLineLayer)
    }
    
    private func configureMenuButtons() {
        subviews
            .compactMap { subview in
                subview as? UIButton
            }
            .forEach { button in
                button.addTarget(
                    self,
                    action: #selector(moveUnderLine),
                    for: .touchUpInside
                )
            }
    }
        
    @objc private func moveUnderLine(_ sender: UIButton) {
        let destinationX = sender.frame.origin.x + sender.frame.width / 2
        
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
