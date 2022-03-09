//
//  CoinTransactionViewInstantiateInformation.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/08.
//

import Foundation

struct CoinTransactionViewInstantiateInformation: ViewControllerinstantiatable {
    var storyboardName: String
    var viewControllerName: String
    
    init(
        storyboardName: String = "CoinTransaction",
        viewControllerName: String = "CoinTransactionViewController"
    ) {
        self.storyboardName = storyboardName
        self.viewControllerName = viewControllerName
    }
}
