//
//  BallonSpeakView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/07.
//

import UIKit

final class BallonSpeakView: UIView {
    
    @IBOutlet private weak var backgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        backgroundView.backgroundColor = .clear
        configureBackgroundLayer()
    }
    
    func configureBackgroundLayer() {
        let roundedBackgroundLayer = CAShapeLayer()

        roundedBackgroundLayer.frame = CGRect(
            x: 0,
            y: 10,
            width: frame.size.width,
            height: frame.size.height - 10
        )
        roundedBackgroundLayer.backgroundColor = UIColor.systemGray6.cgColor
        roundedBackgroundLayer.cornerRadius = 10
        
        backgroundView.layer.addSublayer(roundedBackgroundLayer)
        
        let tailLayer = CAShapeLayer()
        let tailPath = UIBezierPath()
        tailLayer.strokeColor = UIColor.clear.cgColor
        tailLayer.fillColor = UIColor.systemGray6.cgColor
        tailLayer.lineWidth = 1
        
        tailPath.lineCapStyle = .round
        tailPath.move(to: CGPoint(x: 8, y: 12))
        tailPath.addLine(to: CGPoint(x: 18, y: 0))
        tailPath.addLine(to: CGPoint(x: 28, y: 12))
        
        tailLayer.path = tailPath.cgPath
        
        backgroundView.layer.addSublayer(tailLayer)
    }
}
