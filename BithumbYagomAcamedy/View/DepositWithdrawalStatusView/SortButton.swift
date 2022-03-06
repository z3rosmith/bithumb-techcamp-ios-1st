//
//  SortButton.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/01.
//

import UIKit

class SortButton: UIButton {
    
    private(set) var isAscend: Bool
    private let defaultImageName = "chevron_all_gray"
    private let upImageName = "chevron_up_black"
    private let downImageName = "chevron_under_black"
    
    required init?(coder: NSCoder) {
        self.isAscend = false
        super.init(coder: coder)
        commonInit()
    }
    
    func update(title: String) {
        setTitle(title, for: .normal)
    }
    
    func restoreButton() {
        setImage(UIImage(named: defaultImageName), for: .normal)
        self.isAscend = false
    }
    
    private func commonInit() {
        titleLabel?.adjustsFontForContentSizeCategory = true
        setImage(UIImage(named: defaultImageName), for: .normal)
        addTarget(self, action: #selector(touchedSortButton), for: .touchUpInside)
    }
    
    @objc private func touchedSortButton() {
        self.isAscend = !isAscend
        
        if isAscend {
            setImage(UIImage(named: upImageName), for: .normal)
        } else {
            setImage(UIImage(named: downImageName), for: .normal)
        }
    }
}
