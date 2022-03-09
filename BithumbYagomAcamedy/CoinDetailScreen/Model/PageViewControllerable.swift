//
//  PageViewControllerable.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/09.
//

import Foundation

protocol PageViewControllerable {
    var completion: (() -> Void)? { get set }
    func configureDataManager(coin: Coin)
}
