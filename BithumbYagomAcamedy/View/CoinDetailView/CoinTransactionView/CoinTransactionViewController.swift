//
//  CoinTransactionViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

class CoinTransactionViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var coinTransactionCollectionView: UICollectionView!
    
    // MARK: - Property
    private let coinTransactionDataManager = CoinTransactionDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coinTransactionDataManager.fetchTransaction()
        coinTransactionDataManager.fetchTransactionWebSocket()
    }
}
