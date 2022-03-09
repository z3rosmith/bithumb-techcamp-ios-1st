//
//  CoinDetailViewInstantiateInformation.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/09.
//

import Foundation

struct CoinDetailViewInstantiateInformation: ViewControllerInstantiatable {
    private(set) var storyboardName: String
    private(set) var viewControllerName: String
    
    init(
        storyboardName: String = "CoinDetail",
        viewControllerName: String = "CoinDetailViewController"
    ) {
        self.storyboardName = storyboardName
        self.viewControllerName = viewControllerName
    }
}
