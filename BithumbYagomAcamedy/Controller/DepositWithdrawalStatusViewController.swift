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
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameSortButton: SortButton!
    @IBOutlet weak var depositSortButton: SortButton!
    @IBOutlet weak var withdrawalSortButton: SortButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Property
    
    private var dataManager: DepositWithdrawalStatusDataManager?
    private var dataSource: UICollectionViewDiffableDataSource<Section, AssetsStatus>?
    private let depositWithdrawalCollectionViewCellNibName = "DepositWithdrawalCollectionViewCell"
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusSearchBar.endEditing(false)
        configureCollectionViewLayout()
        configureDiffableDataSource()
        configureDataManager()
        applyDepositWithdrawalStatusData()
    }
    
    @objc func touched() {
        print("Hi")
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
            self?.applyData(with: assetsStatuses)
        }
    }
    
    private func applyData(with data: [AssetsStatus]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AssetsStatus>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        
        DispatchQueue.main.async { [weak self] in
            self?.dataSource?.apply(snapshot)
        }
    }
    
    private func filteredAssetsStatusesBySegmentedContorl() -> [AssetsStatus] {
        guard let dataManager = dataManager else {
            return []
        }
        let filteredData = dataManager.filterStatuses(by: .init(rawValue: filterSegmentedControl.selectedSegmentIndex))
        
        return filteredData
    }
    
    private func restoreButtonImages() {
        nameSortButton.restoreImage()
        depositSortButton.restoreImage()
        withdrawalSortButton.restoreImage()
    }
    
    // MARK: - IBAction
    
    @IBAction func filterSegmentedControlValueChanged(_ sender: Any) {
        let filteredData = filteredAssetsStatusesBySegmentedContorl()
        
        applyData(with: filteredData)
        restoreButtonImages()
    }
    
    @IBAction func nameSortButtonTouched(_ sender: Any) {
        guard let dataManager = dataManager else {
            return
        }
        let items = filteredAssetsStatusesBySegmentedContorl()
        let sortedData = dataManager.sortStatuses(data: items, by: .name, nameSortButton.isAscend)
        
        applyData(with: sortedData)
        restoreButtonImages()
    }
    
    @IBAction func depositSortButtonTouched(_ sender: Any) {
        guard let dataManager = dataManager else {
            return
        }
        let items = filteredAssetsStatusesBySegmentedContorl()
        let sortedData = dataManager.sortStatuses(data: items, by: .deposit, depositSortButton.isAscend)
        
        applyData(with: sortedData)
        restoreButtonImages()
    }
    
    @IBAction func withdrawalButtonTouched(_ sender: Any) {
        guard let dataManager = dataManager else {
            return
        }
        let items = filteredAssetsStatusesBySegmentedContorl()
        let sortedData = dataManager.sortStatuses(data: items, by: .deposit, withdrawalSortButton.isAscend)
        
        applyData(with: sortedData)
        restoreButtonImages()
    }
}

// MARK: - Extension

// MARK: Search bar delegate

extension DepositWithdrawalStatusViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let dataManager = dataManager else {
            return
        }
        
        guard !searchText.isEmpty else {
            applyData(with: dataManager.statuses)
            return
        }
        
        let filteredData = dataManager.containStatuses(in: searchText)
        
        applyData(with: filteredData)
    }
}
