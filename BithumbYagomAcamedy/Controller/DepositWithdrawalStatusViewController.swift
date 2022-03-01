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
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Property
    
    private var dataManager: DepositWithdrawalStatusDataManager?
    private var dataSource: UICollectionViewDiffableDataSource<Section, AssetsStatus>?
    private let depositWithdrawalCollectionViewCellNibName = "DepositWithdrawalCollectionViewCell"
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViewLayout()
        configureDiffableDataSource()
        configureDataManager()
        applyDepositWithdrawalStatusData()
    }
    
    // MARK: - Configuration
    
    private func configureCollectionViewLayout() {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        
        collectionView.collectionViewLayout = layout
    }
    
    private func configureDiffableDataSource() {
        typealias CellRegistration = UICollectionView.CellRegistration<
            DepositWithdrawalCollectionViewCell, AssetsStatus
        >
        
        let depositWithdrawalCell = UINib(nibName: depositWithdrawalCollectionViewCellNibName, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: depositWithdrawalCell) { cell, indexPath, item in
            cell.update(item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, AssetsStatus>(
            collectionView: collectionView
        ) { collectionView, indexPath, data -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: data
            )
        }
    }
    
    private func configureDataManager() {
        dataManager = DepositWithdrawalStatusDataManager()
    }
    
    private func applyDepositWithdrawalStatusData() {
        dataManager?.requestData { [weak self] assetsStatuses in
            var snapshot = NSDiffableDataSourceSnapshot<Section, AssetsStatus>()
            
            snapshot.appendSections([.main])
            snapshot.appendItems(assetsStatuses, toSection: .main)
            self?.dataSource?.apply(snapshot)
        }
    }
}
