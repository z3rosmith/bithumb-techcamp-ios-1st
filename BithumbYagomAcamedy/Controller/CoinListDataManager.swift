//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

protocol CoinListDataManagerDelegate: AnyObject {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManager(didToggleFavorite favoriteCoinList: [Coin], allCoinList: [Coin])
}

final class CoinListDataManager {
    
    // MARK: - Nested Type
    
    enum SortType {
        case popularity(isDescend: Bool)
        case name(isDescend: Bool)
        case price(isDescend: Bool)
        case changeRate(isDescend: Bool)
    }
    
    enum SortOption {
        case sortFavorite
        case sortAll
        case sortBoth
    }
    
    // MARK: - Property
    
    weak var delegate: CoinListDataManagerDelegate?
    private let successStatusCode = "0000"
    private let httpNetworkService: HTTPNetworkService
    private var favoriteCoinList: [Coin] = []
    private var allCoinList: [Coin] = []
    
    private var currentFavoriteSortType: SortType
    private var currentAllSortType: SortType
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        initialSortType: SortType = .popularity(isDescend: true)
    ) {
        self.httpNetworkService = httpNetworkService
        self.currentFavoriteSortType = initialSortType
        self.currentAllSortType = initialSortType
    }
}

// MARK: - Data Processing

extension CoinListDataManager {
    func toggleFavorite(coinCallingName: String, isAlreadyFavorite: Bool, filteredBy text: String?) {
        guard let indexOfAllCoinList = allCoinList.firstIndex(where: {
            $0.callingName == coinCallingName
        }) else {
            return
        }
        
        if isAlreadyFavorite {
            if let index = favoriteCoinList.firstIndex(where: {
                $0.callingName == coinCallingName
            }) {
                favoriteCoinList.remove(at: index)
            }
        } else {
            let favoritedCoin = Coin(toggleFavorite: allCoinList[indexOfAllCoinList])
            favoriteCoinList.append(favoritedCoin)
        }
        
        allCoinList[indexOfAllCoinList].isFavorite.toggle()
        
        let sortedFavoriteCoinList = favoriteCoinList.sorted(by: currentFavoriteSortType).filter(by: text)
        let sortedAllCoinList = allCoinList.sorted(by: currentAllSortType).filter(by: text)
        
        delegate?.coinListDataManager(didToggleFavorite: sortedFavoriteCoinList, allCoinList: sortedAllCoinList)
    }
    
    func sortCoinList(what list: SortOption, by sortType: SortType, filteredBy text: String?) {
        var sortedFavoriteCoinList: [Coin] = favoriteCoinList
        var sortedAllCoinList: [Coin] = allCoinList
        
        switch list {
        case .sortFavorite:
            currentFavoriteSortType = sortType
            sortedFavoriteCoinList = favoriteCoinList.sorted(by: sortType).filter(by: text)
        case .sortAll:
            currentAllSortType = sortType
            sortedAllCoinList = allCoinList.sorted(by: sortType).filter(by: text)
        case .sortBoth:
            currentFavoriteSortType = sortType
            currentAllSortType = sortType
            sortedFavoriteCoinList = favoriteCoinList.sorted(by: sortType).filter(by: text)
            sortedAllCoinList = allCoinList.sorted(by: sortType).filter(by: text)
        }
        
        delegate?.coinListDataManager(didChangeCoinList: sortedFavoriteCoinList, allCoinList: sortedAllCoinList)
    }
    
    func filterCoinList(by text: String) {
        let filteredFavoriteCoinList = favoriteCoinList.sorted(by: currentFavoriteSortType).filter(by: text)
        let filteredAllCoinList = allCoinList.sorted(by: currentAllSortType).filter(by: text)
        
        delegate?.coinListDataManager(didChangeCoinList: filteredFavoriteCoinList, allCoinList: filteredAllCoinList)
    }
}

// MARK: - Networking

extension CoinListDataManager {
    func fetchCoinList() {
        httpNetworkService.request(api: TickerAPI()) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONParser().decode(data: data, type: TickersValueObject.self)
                    // TODO: response.status가 "0000"이 아닐 때 처리하기
                    guard response.status == self?.successStatusCode else { return }
                    self?.setCoinList(from: response)
                    self?.fetchCurrentPrice()
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setCoinList(from response: TickersValueObject) {
        response.ticker.forEach { key, dynamicValue in
            if let tickerData = dynamicValue.tickerData {
                let coin = Coin(
                    callingName: NSLocalizedString(key, comment: ""),
                    symbolName: key,
                    currentPrice: 0,
                    changeRate: Double(tickerData.fluctateRate24Hour),
                    changePrice: Double(tickerData.fluctate24Hour),
                    popularity: Double(tickerData.accTradeValue24Hour),
                    isFavorite: false
                )
                allCoinList.append(coin)
            }
        }
        // TODO: favoriteCoinList 를 CoreData에서 가져오는 로직 추가
    }
    
    private func fetchCurrentPrice() {
        var count: Int = 0
        let serialQueue = DispatchQueue(label: "serial")
        
        for i in 0..<allCoinList.count {
            let api = TransactionHistoryAPI(orderCurrency: allCoinList[i].symbolName)
            httpNetworkService.request(api: api) { [weak self] result in
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONParser().decode(data: data, type: TranscationValueObject.self)
                        guard response.status == self?.successStatusCode else {
                            print(response.status)
                            return
                        }
                        if let firstItem = response.transaction.first {
                            self?.allCoinList[i].currentPrice = Double(firstItem.price)
                            serialQueue.async {
                                count += 1
                                if count == self?.allCoinList.count,
                                   let self = self {
                                    self.sortCoinList(what: .sortBoth, by: .popularity(isDescend: true), filteredBy: nil)
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

private extension Array where Element == Coin {
    func sorted(by sortType: CoinListDataManager.SortType) -> [Element] {
        let sortedCoinList: [Element]
        switch sortType {
        case .popularity(let isDescend):
            if isDescend {
                sortedCoinList = self.sorted {
                    let first = $0.popularity ?? -Double.greatestFiniteMagnitude
                    let second = $1.popularity ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                sortedCoinList = self.sorted {
                    let first = $0.popularity ?? Double.greatestFiniteMagnitude
                    let second = $1.popularity ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        case .name(let isDescend):
            if isDescend {
                sortedCoinList = self.sorted { $0.callingName > $1.callingName }
            } else {
                sortedCoinList = self.sorted { $0.callingName < $1.callingName }
            }
        case .price(let isDescend):
            if isDescend {
                sortedCoinList = self.sorted {
                    let first = $0.currentPrice ?? -Double.greatestFiniteMagnitude
                    let second = $1.currentPrice ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                sortedCoinList = self.sorted {
                    let first = $0.currentPrice ?? Double.greatestFiniteMagnitude
                    let second = $1.currentPrice ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        case .changeRate(let isDescend):
            if isDescend {
                sortedCoinList = self.sorted {
                    let first = $0.changeRate ?? -Double.greatestFiniteMagnitude
                    let second = $1.changeRate ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                sortedCoinList = self.sorted {
                    let first = $0.changeRate ?? Double.greatestFiniteMagnitude
                    let second = $1.changeRate ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        }
        return sortedCoinList
    }
    
    func filter(by text: String?) -> [Element] {
        guard let text = text,
              text.isEmpty == false
        else { return self }
        
        return self.filter {
            $0.callingName.localizedStandardContains(text) ||
                $0.symbolName.localizedStandardContains(text)
        }
    }
}
