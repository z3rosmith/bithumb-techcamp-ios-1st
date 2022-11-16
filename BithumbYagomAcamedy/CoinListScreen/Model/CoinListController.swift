//
//  CoinListController.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/11/16.
//

import Foundation

final class CoinListController {
    private var favoriteCoins: CoinListWithBackup
    private var allCoins: CoinListWithBackup
    private let favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager
    
    init(
        fetchedCoinList: [ViewCoin],
        selectedButton: CoinSortButton?,
        favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager = .init()
    ) {
        let favoriteCoinsSymbols = favoriteCoinCoreDataManager.fetch()
        let acoins = fetchedCoinList.map { coin in
            if favoriteCoinsSymbols.contains(coin.symbolName) {
                var copy = coin.copy()
                copy.toggleFavorite()
                return copy
            }
            return coin
        }
        let fcoins = acoins.filter { $0.isFavorite }
        
        allCoins = CoinListWithBackup(coins: acoins)
        self.favoriteCoinCoreDataManager = favoriteCoinCoreDataManager
        favoriteCoins = CoinListWithBackup(coins: fcoins)
        
        if let selectedButton {
            allCoins.sort(using: selectedButton)
            favoriteCoins.sort(using: selectedButton)
        }
    }
    
    func getSectionModel() -> [CoinListSectionModel] {
        var sectionModel: [CoinListSectionModel] = []
        
        if favoriteCoins.list.isEmpty == false {
            sectionModel.append(CoinListSectionModel(model: "관심", items: favoriteCoins.list))
        }
        
        if allCoins.list.isEmpty == false {
            sectionModel.append(CoinListSectionModel(model: "원화", items: allCoins.list))
        }
        
        return sectionModel
    }
    
    func sort(using coinSortButton: CoinSortButton) {
        favoriteCoins.sort(using: coinSortButton)
        allCoins.sort(using: coinSortButton)
    }
    
    func filter(by text: String?) {
        favoriteCoins.filter(by: text)
        allCoins.filter(by: text)
    }
    
    func favorite(indexPath: IndexPath) {
        let index = indexPath.item
        
        /// favoriteCoinList가 비어있는 경우는 무조건 좋아요 하는 경우임
        if favoriteCoins.list.isEmpty {
            let coin = allCoins.toggleFavorite(index: index)
            favoriteCoins.append(coin)
            favoriteCoinCoreDataManager.save(symbol: coin.symbolName)
            return
        }
        
        /// favoriteCoinList가 비어있지 않은 경우는
        /// indexPath.section == 0이면 무조건 좋아요 취소 하는 경우
        /// indexPath.section == 1이면 isFavorite == true이면 좋아요 취소, 그렇지 않으면 좋아요 하는 경우
        if indexPath.section == 0 {
            let coin = favoriteCoins.remove(at: index)
            favoriteCoinCoreDataManager.delete(symbol: coin.symbolName)
            
            if let index = allCoins.list.searchIndex(with: coin.symbolName) {
                allCoins.toggleFavorite(index: index)
            }
            
            return
        }
        
        let isFavorite = allCoins.list[index].isFavorite
        let coin = allCoins.toggleFavorite(index: index)
        
        if isFavorite {
            if let index = favoriteCoins.list.searchIndex(with: coin.symbolName) {
                favoriteCoins.remove(at: index)
                favoriteCoinCoreDataManager.delete(symbol: coin.symbolName)
            }
        } else {
            favoriteCoins.append(coin)
            favoriteCoinCoreDataManager.save(symbol: coin.symbolName)
        }
    }
    
    func item(for indexPath: IndexPath) -> ViewCoin {
        let index = indexPath.item
        let section = indexPath.section
        if favoriteCoins.list.isEmpty == false {
            if section == 0 {
                return favoriteCoins.list[index]
            } else {
                return allCoins.list[index]
            }
        }
        return allCoins.list[index]
    }
    
    func isFavoriteCoin(for indexPath: IndexPath) -> Bool {
        return item(for: indexPath).isFavorite
    }
    
    func update(
        transactionData: WebSocketTransactionData.WebSocketTransaction,
        indexPathsForVisibleCells: [IndexPath]
    ) -> [CellUpdateData] {
        let data1 = updateCell(
            from: favoriteCoins,
            section: sectionOfFavoriteCoins,
            transactionData: transactionData,
            indexPathsForVisibleCells: indexPathsForVisibleCells
        )
        let data2 = updateCell(
            from: allCoins,
            section: sectionOfAllCoins,
            transactionData: transactionData,
            indexPathsForVisibleCells: indexPathsForVisibleCells
        )
        var dataList: [CellUpdateData] = []
        if let data1 {
            dataList.append(data1)
        }
        if let data2 {
            dataList.append(data2)
        }
        return dataList
    }
    
    private func updateCell(
        from coins: CoinListWithBackup,
        section: Int?,
        transactionData: WebSocketTransactionData.WebSocketTransaction,
        indexPathsForVisibleCells: [IndexPath]
    ) -> CellUpdateData? {
        let symbol = transactionData.symbol.components(separatedBy: "_")[0]
        
        guard let index = coins.list.firstIndex(where: { $0.symbolName == symbol }),
              let section
        else { return nil }
        
        let indexPath = IndexPath(item: index, section: section)
        
        guard indexPathsForVisibleCells.contains(indexPath),
              let newPrice = Double(transactionData.price)
        else { return nil }
        
        let oldCoin = coins.list[index]
        let (newChangePrice, newChangeRate) = calculateChange(
            pivotPrice: oldCoin.closingPrice,
            newPrice: newPrice
        )
        let oldPrice = oldCoin.currentPrice
        let changePriceStyle: ViewCoin.ChangeStyle
        
        if newPrice > oldPrice {
            changePriceStyle = .up
        } else if newPrice < oldPrice {
            changePriceStyle = .down
        } else {
            changePriceStyle = .none
        }
        
        let newCoin = oldCoin.updated(
            newPrice: newPrice,
            newChangeRate: newChangeRate,
            newChangePrice: newChangePrice,
            changePriceStyle: changePriceStyle
        )
        coins.remove(at: index)
        coins.append(newCoin)
        
        return (indexPath, newCoin)
    }
    
    private func calculateChange(
        pivotPrice: Double,
        newPrice: Double
    ) -> (changePrice: Double, changeRate: Double) {
        let changePrice = newPrice - pivotPrice
        let changeRate = (changePrice / pivotPrice * 10000).rounded() / 100
        return (changePrice, changeRate)
    }
}

// MARK: - Helpers

extension CoinListController {
    var isFavoriteCoinsEmpty: Bool {
        favoriteCoins.list.isEmpty
    }
    
    var isAllCoinsEmpty: Bool {
        allCoins.list.isEmpty
    }
    
    var favoriteCoinsCount: Int {
        favoriteCoins.list.count
    }
    
    var symbolsInAllCoins: [String] {
        allCoins.list.map { $0.symbolName }
    }
    
    var sectionOfFavoriteCoins: Int? {
        isFavoriteCoinsEmpty ? nil : 0
    }
    
    var sectionOfAllCoins: Int? {
        isFavoriteCoinsEmpty ? 0 : 1
    }
}

// MARK: - Nested Type

extension CoinListController {
    final private class CoinListWithBackup {
        private var backup: [ViewCoin]
        private(set) var list: [ViewCoin]
        
        var currentSortButton: CoinSortButton?
        var currentFilterText: String?
        
        init(coins: [ViewCoin]) {
            list = coins
            backup = list
        }
        
        func sort(using coinSortButton: CoinSortButton) {
            backup.sort(using: coinSortButton)
            list.sort(using: coinSortButton)
            
            currentSortButton = coinSortButton
        }
        
        func filter(by text: String?) {
            list = backup.filter(by: text)
            
            currentFilterText = text
        }
        
        @discardableResult
        func toggleFavorite(index: Int) -> ViewCoin {
            let coin = list[index].toggleFavorite()
            if let indexInBackup = backup.searchIndex(with: coin.symbolName) {
                backup[indexInBackup].toggleFavorite()
            }
            return coin
        }
        
        func append(_ coin: ViewCoin) {
            list.append(coin)
            backup.append(coin)
            
            if let currentSortButton {
                sort(using: currentSortButton)
            }
        }
        
        @discardableResult
        func remove(at index: Int) -> ViewCoin {
            let removedCoin = list.remove(at: index)
            if let indexInBackup = backup.searchIndex(with: removedCoin.symbolName) {
                backup.remove(at: indexInBackup)
            }
            return removedCoin
        }
    }
}
