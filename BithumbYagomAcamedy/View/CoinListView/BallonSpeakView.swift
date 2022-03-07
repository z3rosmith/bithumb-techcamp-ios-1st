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
        let unit = frame.size.height * 0.15
        
        let roundedBackgroundLayer = CAShapeLayer()
        roundedBackgroundLayer.frame = CGRect(
            x: 0,
            y: unit,
            width: frame.size.width,
            height: frame.size.height - unit
        )
        roundedBackgroundLayer.backgroundColor = UIColor.systemGray6.cgColor
        roundedBackgroundLayer.cornerRadius = unit
        
        backgroundView.layer.addSublayer(roundedBackgroundLayer)
        
        let tailLayer = CAShapeLayer()
        let tailPath = UIBezierPath()
        tailLayer.strokeColor = UIColor.clear.cgColor
        tailLayer.fillColor = UIColor.systemGray6.cgColor
        tailLayer.lineWidth = 1
        
        tailPath.lineCapStyle = .round
        tailPath.move(to: CGPoint(x: unit, y: unit + 2))
        tailPath.addLine(to: CGPoint(x: unit * 2, y: 0))
        tailPath.addLine(to: CGPoint(x: unit * 3, y: unit + 2))
        
        tailLayer.path = tailPath.cgPath
        
        backgroundView.layer.addSublayer(tailLayer)
    }
}
