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
    
    struct MockData: Hashable {
        let name: String
        let symbol: String
        let depositStatus: Bool
        let withdrawalStatus: Bool
        let uuid: UUID
        
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
                                name: "Test",
                                symbol: "1",
                                depositStatus: true,
                                withdrawalStatus: true,
                                uuid: UUID()),
                              MockData(
                                name: "Test",
                                symbol: "2",
                                depositStatus: true,
                                withdrawalStatus: true,
                                uuid: UUID()),
                              MockData(
                                name: "Test",
                                symbol: "3",
                                depositStatus: true,
                                withdrawalStatus: true,
                                uuid: UUID())])
        dataSource?.apply(snapshot)
    }
}
