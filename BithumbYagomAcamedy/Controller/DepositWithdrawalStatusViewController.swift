//
//  DepositWithdrawalStatusViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/25.
//

import UIKit

final class DepositWithdrawalStatusViewController: UIViewController {
    
    // MARK: - Section
    
    private enum Section {
        case main
    }
    
    // MARK: - Nested Type
    
    struct MockData: DepositWithdrawalCellDataProviding, Hashable {
        private(set) var coinName: String
        private(set) var coinSymbol: String
        private(set) var depositStatus: String
        private(set) var withdrawalStatus: String
        private(set) var isValidDeposit: Bool
        private(set) var isValidWithdrawal: Bool
        let uuid: UUID = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        
        static func ==(lhs: MockData, rhs: MockData) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Property
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, MockData>?
    private let depositWithdrawalCollectionViewCellNibName = "DepositWithdrawalCollectionViewCell"
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureDiffableDataSource()
        configureMockData()
    }
    
    // MARK: - Configuration
    
    private func configureCollectionViewLayout() {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        
        collectionView.collectionViewLayout = layout
    }
    
    private func configureDiffableDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<DepositWithdrawalCollectionViewCell, MockData>
        
        let depositWithdrawalCell = UINib(nibName: depositWithdrawalCollectionViewCellNibName, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: depositWithdrawalCell) { cell, indexPath, item in
            cell.update(item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, MockData>(collectionView: collectionView) { collectionView, indexPath, data -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: data)
        }
    }
    
    private func configureMockData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MockData>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems([MockData(
                                coinName: "비트코인",
                                coinSymbol: "BTC/KRW",
                                depositStatus: "정상",
                                withdrawalStatus: "정상",
                                isValidDeposit: true,
                                isValidWithdrawal: true),
                              MockData(
                                coinName: "이더리움",
                                coinSymbol: "ETH/KRW",
                                depositStatus: "정상",
                                withdrawalStatus: "중단",
                                isValidDeposit: true,
                                isValidWithdrawal: false),
                              MockData(
                                coinName: "Test1",
                                coinSymbol: "TST/KRW",
                                depositStatus: "정상",
                                withdrawalStatus: "정상",
                                isValidDeposit: true,
                                isValidWithdrawal: true),
                              MockData(
                                coinName: "Test2",
                                coinSymbol: "TST/KRW",
                                depositStatus: "정상",
                                withdrawalStatus: "중단",
                                isValidDeposit: true,
                                isValidWithdrawal: false),
                              MockData(
                                coinName: "Test3",
                                coinSymbol: "TST/KRW",
                                depositStatus: "중단",
                                withdrawalStatus: "중단",
                                isValidDeposit: false,
                                isValidWithdrawal: false)
                             ])
        dataSource?.apply(snapshot)
    }
}
