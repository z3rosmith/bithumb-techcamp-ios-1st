//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

protocol CoinListDataManagerDelegate {
    func coinListDataManager(didFetchCurrentPrice favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManager(didSortCoinList favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManager(didToggleFavorite favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManager(didFilterCoinList filteredFavoriteCoinList: [Coin], filteredAllCoinList: [Coin])
}

final class CoinListDataManager {
    
    // MARK: - Nested Type
    
    enum CoinSortType {
        case popularity(isDescend: Bool)
        case name(isDescend: Bool)
        case price(isDescend: Bool)
        case changeRate(isDescend: Bool)
    }
    
    // MARK: - Property
    
    var delegate: CoinListDataManagerDelegate?
    private let successStatusCode = "0000"
    private let httpNetworkService: HTTPNetworkService
    private var currentFavoriteSortType: CoinSortType
    private var currentAllSortType: CoinSortType
    
    private var favoriteCoinList: [Coin] = []
    private var allCoinList: [Coin] = []
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        initialSortType: CoinSortType = .popularity(isDescend: true)
    ) {
        self.httpNetworkService = httpNetworkService
        self.currentFavoriteSortType = initialSortType
        self.currentAllSortType = initialSortType
    }
}

// MARK: - Data Processing

extension CoinListDataManager {
    func toggleFavorite(coinCallingName: String, isAlreadyFavorite: Bool) {
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
        delegate?.coinListDataManager(didToggleFavorite: favoriteCoinList, allCoinList: allCoinList)
    }
    
    func sortCoinList(for section: CoinListViewController.Section, by sortType: CoinSortType) {
        switch section {
        case .favorite:
            currentFavoriteSortType = sortType
            sortCoinList(coinList: &favoriteCoinList, by: sortType)
        case .all:
            currentAllSortType = sortType
            sortCoinList(coinList: &allCoinList, by: sortType)
        }
    }
    
    private func sortCoinList(coinList: inout [Coin], by sortType: CoinSortType) {
        switch sortType {
        case .popularity(let isDescend):
            if isDescend {
                coinList.sort {
                    let first = $0.popularity ?? -Double.greatestFiniteMagnitude
                    let second = $1.popularity ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                coinList.sort {
                    let first = $0.popularity ?? Double.greatestFiniteMagnitude
                    let second = $1.popularity ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        case .name(let isDescend):
            if isDescend {
                coinList.sort { $0.callingName > $1.callingName }
            } else {
                coinList.sort { $0.callingName < $1.callingName }
            }
        case .price(let isDescend):
            if isDescend {
                coinList.sort {
                    let first = $0.currentPrice ?? -Double.greatestFiniteMagnitude
                    let second = $1.currentPrice ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                coinList.sort {
                    let first = $0.currentPrice ?? Double.greatestFiniteMagnitude
                    let second = $1.currentPrice ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        case .changeRate(let isDescend):
            if isDescend {
                coinList.sort {
                    let first = $0.changeRate ?? -Double.greatestFiniteMagnitude
                    let second = $1.changeRate ?? -Double.greatestFiniteMagnitude
                    return first > second
                }
            } else {
                coinList.sort {
                    let first = $0.changeRate ?? Double.greatestFiniteMagnitude
                    let second = $1.changeRate ?? Double.greatestFiniteMagnitude
                    return first < second
                }
            }
        }
        delegate?.coinListDataManager(didSortCoinList: favoriteCoinList, allCoinList: allCoinList)
    }
    
//    private func sortedCoinList(coinList: [Coin], by sortType: CoinSortType) -> [Coin] {
//        currentSortType = sortType
//        var coinList = coinList
//        sortCoinList(coinList: &coinList, by: sortType)
//        return coinList
//    }
    
    func filterCoinList(by text: String) {
        if text.isEmpty {
            delegate?.coinListDataManager(didFilterCoinList: favoriteCoinList, filteredAllCoinList: allCoinList)
        } else {
            let filteredFavoriteCoinList = favoriteCoinList.filter {
                $0.callingName.localizedStandardContains(text) ||
                    $0.symbolName.localizedStandardContains(text)
            }
            let filteredAllCoinList = allCoinList.filter {
                $0.callingName.localizedStandardContains(text) ||
                    $0.symbolName.localizedStandardContains(text)
            }
            delegate?.coinListDataManager(didFilterCoinList: filteredFavoriteCoinList, filteredAllCoinList: filteredAllCoinList)
        }
    }
    
//    private func setFilteredCoinListDefaultValue() {
//        filteredFavoriteCoinList = sortedCoinList(coinList: favoriteCoinList, by: currentSortType)
//        filteredAllCoinList = sortedCoinList(coinList: allCoinList, by: currentSortType)
//        delegate?.coinListDataManager(didSortCoinList: filteredFavoriteCoinList, allCoinList: filteredAllCoinList)
//    }
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
                                    self.sortCoinList(coinList: &self.favoriteCoinList, by: self.currentFavoriteSortType)
                                    self.sortCoinList(coinList: &self.allCoinList, by: self.currentAllSortType)
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

struct Coin: Hashable {
    let callingName: String
    let symbolName: String
    var currentPrice: Double?
    var changeRate: Double?
    var changePrice: Double?
    var popularity: Double?
    var isFavorite: Bool
    let identifier = UUID()
    
    init(
        callingName: String,
        symbolName: String,
        currentPrice: Double?,
        changeRate: Double?,
        changePrice: Double?,
        popularity: Double?,
        isFavorite: Bool
    ) {
        self.callingName = callingName
        self.symbolName = symbolName
        self.currentPrice = currentPrice
        self.changeRate = changeRate
        self.changePrice = changePrice
        self.popularity = popularity
        self.isFavorite = isFavorite
    }
    
    init(toggleFavorite coin: Coin) {
        self.callingName = coin.callingName
        self.symbolName = coin.symbolName
        self.currentPrice = coin.currentPrice
        self.changeRate = coin.changeRate
        self.changePrice = coin.changePrice
        self.popularity = coin.popularity
        self.isFavorite = !coin.isFavorite
    }
}

// MARK: - Coin Computed Property

extension Coin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        guard let currentPrice = currentPrice else {
            return "오류발생"
        }
        return String(currentPrice)
    }
    
    var changeRateString: String {
        guard let changeRate = changeRate else {
            return "오류발생"
        }
        return String(changeRate)
    }
    
    var changePriceString: String {
        guard let changePrice = changePrice else {
            return "오류발생"
        }
        return String(changePrice)
    }
}

