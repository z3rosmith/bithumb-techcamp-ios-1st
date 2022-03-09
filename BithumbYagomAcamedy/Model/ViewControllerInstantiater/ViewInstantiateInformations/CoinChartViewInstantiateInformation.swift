//
//  CoinChartViewInstantiateInformation.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/08.
//

import Foundation

struct CoinChartViewInstantiateInformation: ViewControllerinstantiatable {
    var storyboardName: String
    var viewControllerName: String
    
    init(
        storyboardName: String = "CoinChart",
        viewControllerName: String = "CoinChartViewController"
    ) {
        self.storyboardName = storyboardName
        self.viewControllerName = viewControllerName
    }
}
