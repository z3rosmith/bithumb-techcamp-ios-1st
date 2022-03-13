//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

protocol CoinListDataManagerDelegate: AnyObject {
    func coinListDataManager(didChangeCoinList favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManager(didSetCurrentPriceInAllCoinList favoriteCoinList: [Coin], allCoinList: [Coin])
    func coinListDataManagerDidFetchFail()
}

final class CoinListDataManager {
    
    // MARK: - Nested Type
    
    enum SortType {
        case popularity(isDescend: Bool)
        case name(isDescend: Bool)
        case price(isDescend: Bool)
        case changeRate(isDescend: Bool)
    }
    
    // MARK: - Property
    
    weak var delegate: CoinListDataManagerDelegate?
    private let successStatusCode = "0000"
    private let httpNetworkService: HTTPNetworkService
    private var webSocketService: WebSocketService
    private let favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager
    
    private var favoriteCoinList: [Coin] = []
    private var allCoinList: [Coin] = []
    private var filteredFavoriteCoinList: [Coin] = []
    private var filteredAllCoinList: [Coin] = []
    
    private var currentSortType: SortType
    
    var visibleCellsSymbols: [String] = []
    
    // MARK: - Init
    
    init(
        httpNetworkService: HTTPNetworkService = HTTPNetworkService(),
        webSocketService: WebSocketService = WebSocketService(),
        favoriteCoinCoreDataManager: FavoriteCoinCoreDataManager = FavoriteCoinCoreDataManager(),
        initialSortType: SortType = .popularity(isDescend: true)
    ) {
        self.httpNetworkService = httpNetworkService
        self.webSocketService = webSocketService
        self.favoriteCoinCoreDataManager = favoriteCoinCoreDataManager
        self.currentSortType = initialSortType
    }
    
    deinit {
        webSocketService.close()
    }
}

// MARK: - Data Processing

extension CoinListDataManager {
    func toggleFavorite(coinSymbolName: String, isAlreadyFavorite: Bool) {
        guard let indexInAllCoinList = allCoinList.firstIndex(where: {
            $0.symbolName == coinSymbolName
        }) else {
            return
        }
        
        if isAlreadyFavorite {
            if let index = favoriteCoinList.firstIndex(where: {
                $0.symbolName == coinSymbolName
            }) {
                favoriteCoinList.remove(at: index)
                favoriteCoinCoreDataManager.delete(symbol: coinSymbolName)
            }
        } else {
            let favoritedCoin = Coin(toggleFavorite: allCoinList[indexInAllCoinList])
            favoriteCoinList.append(favoritedCoin)
            favoriteCoinCoreDataManager.save(symbol: coinSymbolName)
        }
        
        allCoinList[indexInAllCoinList].isFavorite.toggle()
    }
    
    func sortCoinList(by sortType: SortType? = nil, filteredBy text: String? = nil) {
        if let sortType = sortType {
            currentSortType = sortType
        }
        
        filteredFavoriteCoinList = favoriteCoinList.sorted(by: currentSortType).filter(by: text)
        filteredAllCoinList = allCoinList.sorted(by: currentSortType).filter(by: text)
        
        delegate?.coinListDataManager(didChangeCoinList: filteredFavoriteCoinList, allCoinList: filteredAllCoinList)
    }
    
    func filterCoinList(by text: String) {
        filteredFavoriteCoinList = favoriteCoinList.sorted(by: currentSortType).filter(by: text)
        filteredAllCoinList = allCoinList.sorted(by: currentSortType).filter(by: text)
        
        delegate?.coinListDataManager(didChangeCoinList: filteredFavoriteCoinList, allCoinList: filteredAllCoinList)
    }
    
    func nameOfSectionHeader(index: Int) -> String? {
        let favoriteCoinListIsEmpty = filteredFavoriteCoinList.isEmpty
        let allCoinListIsEmpty = filteredAllCoinList.isEmpty
        
        if favoriteCoinListIsEmpty && allCoinListIsEmpty {
            return nil
        } else if favoriteCoinListIsEmpty {
            return "원화"
        } else if allCoinListIsEmpty {
            return "관심"
        } else {
            if index == 0 {
                return "관심"
            } else {
                return "원화"
            }
        }
    }
    
    private func applyCurrentPrice() {
        delegate?.coinListDataManager(didSetCurrentPriceInAllCoinList: filteredFavoriteCoinList, allCoinList: filteredAllCoinList)
    }
}

// MARK: - FavoriteCoinCoreDataManager

extension CoinListDataManager {
    private func fetchFavoriteCoinList() {
        let favoriteSymbolSet = Set(favoriteCoinCoreDataManager.fetch())
        let allSymbolSet = Set(allCoinList.map { $0.symbolName })
        let symbolToToggle = favoriteSymbolSet.intersection(allSymbolSet)
        symbolToToggle.forEach {
            toggleFavorite(coinSymbolName: $0, isAlreadyFavorite: false)
        }
        sortCoinList()
    }
}

// MARK: - HTTP Network

extension CoinListDataManager {
    func fetchCoinList() {
        httpNetworkService.fetch(
            api: TickerAPI(),
            type: TickersValueObject.self
        ) { [weak self] result in
            guard let tickerValueObject = result.value else {
                self?.delegate?.coinListDataManagerDidFetchFail()
                print(result.error?.localizedDescription as Any)
                return
            }
            
            guard tickerValueObject.status == self?.successStatusCode else {
                return
            }
            
            self?.setCoinList(from: tickerValueObject)
            self?.fetchCurrentPrice()
        }
    }
    
    private func setCoinList(from response: TickersValueObject) {
        response.ticker.forEach { key, dynamicValue in
            if let tickerData = dynamicValue.tickerData {
                let coin = Coin(
                    callingName: NSLocalizedString(key, comment: ""),
                    symbolName: key,
                    currentPrice: 0,
                    closingPrice: Double(tickerData.prevClosingPrice),
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
        let group = DispatchGroup()
        for i in 0..<allCoinList.count {
            group.enter()
            let api = TransactionHistoryAPI(orderCurrency: allCoinList[i].symbolName)
            
            httpNetworkService.fetch(
                api: api,
                type: TransactionValueObject.self
            ) { [weak self] result in
                defer {
                    group.leave()
                }
                
                guard let transactionValueObject = result.value,
                      let transactionData = transactionValueObject.transaction.first
                else {
                    return
                }
                
                self?.allCoinList[i].currentPrice = Double(transactionData.price)
            }

            // 빗썸 Public API의 데이터 요청 횟수가 1초에 135개로 제한되어 있어서
            // 1초에 100개를 요청하도록 sleep을 줌
            Thread.sleep(forTimeInterval: 0.01)
        }
        group.notify(queue: .main) { [weak self] in
            self?.fetchFavoriteCoinList()
            self?.fetchCurrentPriceWebSocket()
        }
    }
}

// MARK: - WebSocket Network

extension CoinListDataManager {
    func fetchCurrentPriceWebSocket() {
        let symbols = allCoinList.map { $0.symbolName }
        let api = TransactionWebSocket(symbols: symbols)
        webSocketService.close()
        webSocketService.open(webSocketAPI: api) { [weak self] result in
            guard let message = result.value else {
                print(result.error?.localizedDescription as Any)
                return
            }
            
            switch message {
            case .string(let response):
                let transaction = try? self?.parsedWebSocketTranscation(from: response)
                
                guard let transactionList = transaction?.webSocketTransactionData.list,
                      let transactionFirst = transactionList.first
                else {
                    return
                }
                
                self?.setCurrentValue(currentValue: transactionFirst)
            default:
                break
            }
        }
    }
    
    func stopFetchCurrentPriceWebSocket() {
        webSocketService.close()
    }
    
    private func parsedWebSocketTranscation(
        from string: String
    ) throws -> WebSocketTransactionValueObject {
        do {
            let webSocketTransactionValueObject = try JSONParser().decode(
                string: string,
                type: WebSocketTransactionValueObject.self
            )
            
            return webSocketTransactionValueObject
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func setCurrentValue(
        currentValue: WebSocketTransactionData.WebSocketTransaction
    ) {
        let symbolSlice = currentValue.symbol.components(separatedBy: "_")[0]
        
        guard visibleCellsSymbols.contains(symbolSlice) else {
            return
        }
        
        let newPrice = Double(currentValue.price)
        
        if let indexInAllCoin = filteredAllCoinList.firstIndex(where: { $0.symbolName == symbolSlice }) {
            setChanged(for: &filteredAllCoinList, at: indexInAllCoin, newPrice: newPrice)
        }
        
        if let indexInFavoriteCoin = filteredFavoriteCoinList.firstIndex(where: { $0.symbolName == symbolSlice }) {
            setChanged(for: &filteredFavoriteCoinList, at: indexInFavoriteCoin, newPrice: newPrice)
        }
        
        applyCurrentPrice()
    }
    
    private func setChanged(for coinList: inout [Coin], at index: Int, newPrice: Double?) {
        let pivotPrice = coinList[index].closingPrice
        
        calculateChange(pivotPrice: pivotPrice, newPrice: newPrice) { changePrice, changeRate in
            coinList[index].changePrice = changePrice
            coinList[index].changeRate = changeRate
        }
        
        coinList[index].currentPrice = newPrice
    }
    
    private func calculateChange(
        pivotPrice: Double?,
        newPrice: Double?,
        completion: (_ changePrice: Double, _ changeRate: Double) -> Void
    ) {
        guard let pivotPrice = pivotPrice,
              let newPrice = newPrice
        else {
            return
        }

        let changePrice = newPrice - pivotPrice
        let changeRate = (changePrice / pivotPrice * 10000).rounded() / 100
        
        completion(changePrice, changeRate)
    }
}

// MARK: - Extension Of Array

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
