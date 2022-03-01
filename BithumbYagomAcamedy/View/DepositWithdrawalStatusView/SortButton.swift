//
//  SortButton.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/01.
//

import UIKit

class SortButton: UIButton {
    
    private(set) var isAscend: Bool
    
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
        self.titleLabel?.text = title
    }
    
    override func awakeFromNib() {
        commonInit()
    }
    
    func update(title: String) {
        self.setTitle(title, for: .normal)
    }
    
    func restoreImage() {
        self.setImage(UIImage(named: "chevron_all_gray"), for: .normal)
    }
    
    private func commonInit() {
        self.setImage(UIImage(named: "chevron_all_gray"), for: .normal)
        self.addTarget(self, action: #selector(touchedSortButton), for: .touchUpInside)
    }
    
    @objc private func touchedSortButton() {
        self.isAscend = !isAscend
        
        if isAscend {
            self.setImage(UIImage(named: "chevron_up_black"), for: .normal)
        } else {
            self.setImage(UIImage(named: "chevron_under_black"), for: .normal)
        }
    }
}
