//
//  CoinOrderbookViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/04.
//

import UIKit

class CoinOrderbookViewController: UIViewController {

    private let coinOrderbookDataManager = CoinOrderbookDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataManager()
    }
}

// MARK: - CoinOrderbook DataManager

extension CoinOrderbookViewController {
    private func configureDataManager() {
        coinOrderbookDataManager.delegate = self
        coinOrderbookDataManager.fetchOrderbook()
    }
}

// MARK: - CoinTransaction DataManager Delegate

extension CoinOrderbookViewController: CoinOrderbookDataManagerDelegate {
    func coinOrderbookDataManager(didChange orderbook: [Orderbook]) {
        orderbook.forEach { orderbook in
            print("가격 : \(orderbook.price), 수량 \(orderbook.quantity)")
        }
        print(orderbook.count)
        print("___________")
    }
}
