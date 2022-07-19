//
//  SortButton.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/01.
//

import UIKit

class SortButton: UIButton {
    private(set) var isAscend = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
//    func update(title: String) {
//        setTitle(title, for: .normal)
//    }
    
    func toggle() {
//        touchedSortButton()
    }
    
    func restoreButton() {
//        setImage(UIImage(named: SortButton.initialImageName), for: .normal)
//        isAscend = false
    }
    
    private func configure() {
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
