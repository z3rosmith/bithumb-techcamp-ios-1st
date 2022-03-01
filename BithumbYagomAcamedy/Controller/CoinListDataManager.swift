//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

typealias CoinSortAction = (Coin, Coin) -> Bool

protocol CoinListDataManagerDelegate {
    func coinListDataManagerDidSetCoinList()
    func coinListDataManagerDidFetchCurrentPrice()
}

final class CoinListDataManager {
    
    // MARK: - Property
    
    var delegate: CoinListDataManagerDelegate?
    private let networkService: NetworkService
    private var coinList: [Coin] = []
    
    // MARK: - Init
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
}

// MARK: - Data Processing

extension CoinListDataManager {
    func sortedCoinList(by areInIncreasingOrder: @escaping CoinSortAction) -> [Coin] {
        return coinList.sorted(by: areInIncreasingOrder)
    }
}

// MARK: - Networking

extension CoinListDataManager {
    #warning("response status else 구문 구현 필요")
    func fetchCoinList() {
        networkService.request(api: TickerAPI()) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONParser().decode(data: data, type: TickersValueObject.self)
                    if response.status == "0000" {
                        self?.setCoinList(from: response)
                        #warning("밑에줄 주석처리하면 괜찮음.. 왜??")
//                        self?.delegate?.coinListDataManagerDidSetCoinList()
                        self?.fetchCurrentPrice()
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                if let description = error.errorDescription {
                    print(description)
                }
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
                    changeRate: tickerData.fluctateRate24HourDouble,
                    changePrice: tickerData.fluctate24HourDouble,
                    popularity: tickerData.accTradeValue24HourDouble
                )
                coinList.append(coin)
            }
        }
    }
    
    private func fetchCurrentPrice() {
        var count: Int = 0
        let serialQueue = DispatchQueue(label: "serial")
        for i in 0..<coinList.count {
            let api = TransactionHistoryAPI(orderCurrency: coinList[i].symbolName)
            networkService.request(api: api) { [weak self] result in
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONParser().decode(data: data, type: TranscationValueObject.self)
                        if response.status == "0000" {
                            if let firstItem = response.transaction.first {
                                self?.coinList[i].currentPrice = firstItem.priceDouble
                                serialQueue.async {
                                    count += 1
                                    if count == self?.coinList.count {
                                        self?.delegate?.coinListDataManagerDidFetchCurrentPrice()
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    if let description = error.errorDescription {
                        print(description)
                    }
                }
            }
        }
    }
}

struct Coin: Hashable {
    let callingName: String
    let symbolName: String
    var currentPrice: Double
    var changeRate: Double
    var changePrice: Double
    let popularity: Double
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// MARK: - Coin Computed Property

extension Coin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        return "\(currentPrice)"
    }
    
    var changeRateString: String {
        return "\(changeRate)%"
    }
    
    var changePriceString: String {
        return "\(changePrice)"
    }
}

