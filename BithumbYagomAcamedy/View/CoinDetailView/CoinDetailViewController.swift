//
//  CoinDetailViewController.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/02.
//

import UIKit

final class CoinDetailViewController: UIViewController {

    // MARK: - View
    
    private lazy var titleButton = makeTitleButton(coin: coin)
    
    // MARK: - Property
    
    var coin: Coin?
    private let coinDetailDataManager = CoinDetailDataManager()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureNavigationBackButton()
        configureDataManager()
    }
}

// MARK: - Navigation Bar

extension CoinDetailViewController {
    private func makeTitleButton(coin: Coin?) -> UIButton {
        let titleButton = CoinDetailTitleButton()
        titleButton.configureAttributedTitle(coin: coin)
        
        return titleButton
    }
    
    private func configureTitle() {
        navigationItem.titleView = titleButton
    }
    
    private func configureNavigationBackButton() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.topItem?.title = String()
    }
}

// MARK: - CoinTransaction DataManager

extension CoinDetailViewController {
    private func configureDataManager() {
        coinDetailDataManager.delegate = self
        coinDetailDataManager.fetchTickerWebSocket()
        coinDetailDataManager.fetchTransactionWebSocket()
    }
}

extension CoinDetailViewController: CoinDetailDataManagerDelegate {
    func coinDetailDataManager(didChange coin: CoinDetailDataManager.DetailViewCoin) {
        
    }
}


