//
//  CoinTransactionViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

final class CoinTransactionViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var coinTransactionCollectionView: UICollectionView!
    
    // MARK: - Property
    
    private let coinTransactionDataManager = CoinTransactionDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
}

// MARK: - CoinTransaction DataManager

extension CoinTransactionViewController {
    private func configureDataSource() {
        coinTransactionDataManager.delegate = self
        coinTransactionDataManager.fetchTransaction()
        coinTransactionDataManager.fetchTransactionWebSocket()
    }
}

// MARK: - CoinTransaction DataManager Delegate

extension CoinTransactionViewController: CoinTransactionDataManagerDelegate {
    func coinTransactionDataManager(didChange transactions: [Transaction]) {
        print(transactions.count)
    }
}
