//
//  MainTabBarController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/23.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
    }

    private func configureTabBarItem() {
        tabBar.tintColor = .label
        tabBar.unselectedItemTintColor = .systemGray2
    }
        
}

