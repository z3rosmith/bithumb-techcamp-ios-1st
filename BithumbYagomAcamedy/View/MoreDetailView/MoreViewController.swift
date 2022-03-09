//
//  MoreViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/09.
//

import UIKit

final class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    func configureTabBar() {
        tabBarItem = UITabBarItem(
            title: "더보기",
            image: UIImage(named: "ellipsis"),
            selectedImage: UIImage(named: "ellipsis")
        )
    }
}
