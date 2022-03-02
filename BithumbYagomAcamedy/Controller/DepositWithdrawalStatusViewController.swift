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
    
    @IBOutlet private weak var statusSearchBar: UISearchBar!
    @IBOutlet private weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var nameSortButton: SortButton!
    @IBOutlet private weak var depositSortButton: SortButton!
    @IBOutlet private weak var withdrawalSortButton: SortButton!
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
        dataManager?.delegate = self
        dataManager?.requestData()
    }
    
    private func restoreButtonImages() {
        nameSortButton.restoreImage()
        depositSortButton.restoreImage()
        withdrawalSortButton.restoreImage()
    }
    
    // MARK: - IBAction
    
    @IBAction func filterSegmentedControlValueChanged(_ sender: Any) {
        dataManager?.filteredStatuses(by: .init(rawValue: filterSegmentedControl.selectedSegmentIndex))
        restoreButtonImages()
    }
    
    @IBAction func nameSortButtonTouched(_ sender: Any) {
        dataManager?.sortedStatuses(by: .name, nameSortButton.isAscend)
        restoreButtonImages()
    }
    
    @IBAction func depositSortButtonTouched(_ sender: Any) {
        dataManager?.sortedStatuses(by: .deposit, depositSortButton.isAscend)
        restoreButtonImages()
    }
    
    @IBAction func withdrawalButtonTouched(_ sender: Any) {
        dataManager?.sortedStatuses(by: .withdrawal, withdrawalSortButton.isAscend)
        restoreButtonImages()
    }
}

// MARK: - Extension

// MARK: UISearchBarDelegate

extension DepositWithdrawalStatusViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataManager?.containedStatuses(in: searchText)
    }
}

// MARK: DepositWithdrawalStatusDataManagerDelegate

extension DepositWithdrawalStatusViewController: DepositWithdrawalStatusDataManagerDelegate {
    func depositWithdrawalStatusDataManagerDidSetData(_ statuses: [AssetsStatus]) {
        applyData(with: statuses)
    }
    
    private func applyData(with data: [AssetsStatus]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AssetsStatus>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        
        DispatchQueue.main.async { [weak self] in
            self?.dataSource?.apply(snapshot)
        }
    }
}
