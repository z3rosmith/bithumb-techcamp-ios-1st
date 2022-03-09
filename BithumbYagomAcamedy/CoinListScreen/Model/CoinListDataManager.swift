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
    func coinListDataManager(didSetCurrentPriceInAllCoinList favoriteCoinList: [Coin], allCoinList: [Coin])
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
    
    private func applyCurrentPrice(to item: Coin) {
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
        let group = DispatchGroup()
        for i in 0..<self.allCoinList.count {
            group.enter()
            let api = TransactionHistoryAPI(orderCurrency: self.allCoinList[i].symbolName)
            self.httpNetworkService.request(api: api) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    guard let transactionValueObject = try? self?.parsedTranscationValueObject(from: data),
                          let transactionData = transactionValueObject.transaction.first
                    else {
                        return
                    }
                    self?.allCoinList[i].currentPrice = Double(transactionData.price)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.fetchFavoriteCoinList()
//            self?.fetchCurrentPriceWebSocket()
        }
    }
    
    private func parsedTranscationValueObject(from data: Data) throws -> TranscationValueObject? {
        do {
            let response = try JSONParser().decode(data: data, type: TranscationValueObject.self)
            guard response.status == successStatusCode else {
                print(response.status)
                return nil
            }
            return response
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

// MARK: - WebSocket Network

extension CoinListDataManager {
    private func fetchCurrentPriceWebSocket() {
        let symbols = allCoinList.map { $0.symbolName }
        let api = TransactionWebSocket(symbols: symbols)
        
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
        guard let index = filteredAllCoinList.firstIndex(where: {
            $0.symbolName == symbolSlice
        }) else {
            return
        }
        
        let newPrice = Double(currentValue.price)
        
        filteredAllCoinList[index].currentPrice = newPrice
        applyCurrentPrice(to: filteredAllCoinList[index])
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
