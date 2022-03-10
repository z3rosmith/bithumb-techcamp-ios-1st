//
//  ShadowView.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/05.
//

import UIKit

final class ShadowView: UIView {

    override func awakeFromNib() {
        configureShadow()
    }
    
    private func configureShadow() {
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 5, height: 0)
    }
}
