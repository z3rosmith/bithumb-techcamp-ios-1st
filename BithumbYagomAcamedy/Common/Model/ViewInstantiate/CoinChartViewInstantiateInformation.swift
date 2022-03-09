//
//  CoinChartViewInstantiateInformation.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/08.
//

import Foundation

struct CoinChartViewInstantiateInformation: ViewControllerInstantiatable {
    private(set) var storyboardName: String
    private(set) var viewControllerName: String
    
    init(
        storyboardName: String = "CoinChart",
        viewControllerName: String = "CoinChartViewController"
    ) {
        self.storyboardName = storyboardName
        self.viewControllerName = viewControllerName
    }
}
