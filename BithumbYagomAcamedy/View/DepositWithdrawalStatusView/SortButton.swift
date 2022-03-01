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
    
    override init(frame: CGRect) {
        self.isAscend = false
        super.init(frame: frame)
        commonInit()
    }
    
    init(title: String) {
        self.isAscend = false
        super.init(frame: .zero)
        commonInit()
        setTitle(title, for: .normal)
    }
    
    override func awakeFromNib() {
        commonInit()
    }
    
    func update(title: String) {
        setTitle(title, for: .normal)
    }
    
    func restoreImage() {
        setImage(UIImage(named: defaultImageName), for: .normal)
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
