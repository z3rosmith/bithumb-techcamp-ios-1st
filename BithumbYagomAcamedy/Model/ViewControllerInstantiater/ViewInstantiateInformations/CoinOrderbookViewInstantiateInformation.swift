//
//  CoinOrderbookViewInstantiateInformation.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/08.
//

import Foundation

struct CoinOrderbookViewInstantiateInformation: ViewControllerinstantiatable {
    var storyboardName: String
    var viewControllerName: String
    
    init(
        storyboardName: String = "CoinOrderbook",
        viewControllerName: String = "CoinOrderbookViewController"
    ) {
        self.storyboardName = storyboardName
        self.viewControllerName = viewControllerName
    }
}
