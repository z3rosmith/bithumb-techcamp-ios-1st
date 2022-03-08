//
//  BallonSpeakView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/07.
//

import UIKit

final class BallonSpeakView: UIView {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var backgroundView: UIView!
    
    // MARK: - Property
    
    private lazy var unit: Double = frame.size.height * 0.15
    private let overlapUnit: Double = 2.0
    
    private lazy var roundedBackgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = CGRect(
            x: 0,
            y: unit,
            width: frame.size.width,
            height: frame.size.height - unit
        )
        layer.backgroundColor = UIColor.systemGray6.cgColor
        layer.cornerRadius = unit
        
        return layer
    }()
    
    private lazy var tailLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.systemGray6.cgColor
        layer.lineWidth = 1
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: unit, y: unit + overlapUnit))
        path.addLine(to: CGPoint(x: unit * 2, y: 0))
        path.addLine(to: CGPoint(x: unit * 3, y: unit + overlapUnit))
        
        layer.path = path.cgPath
         
        return layer
    }()
    
    // MARK: - Method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureBallonSpeakView()
        addSublayers()
    }
    
    private func configureBallonSpeakView() {
        backgroundColor = .clear
        backgroundView.backgroundColor = .clear
    }
    
    private func addSublayers() {
        backgroundView.layer.addSublayer(roundedBackgroundLayer)
        backgroundView.layer.addSublayer(tailLayer)
    }
}
