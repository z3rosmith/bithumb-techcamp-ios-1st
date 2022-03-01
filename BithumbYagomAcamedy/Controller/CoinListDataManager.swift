//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

protocol CoinListDataManagerDelegate {
    func coinListDataManagerDidFetchCurrentPrice()
    func coinListDataManagerDidSetCoinSortAction()
}

final class CoinListDataManager {
    
    typealias CoinSortAction = (Coin, Coin) -> Bool
    
    // MARK: - Property
    
    private let successStatusCode = "0000"
    private let networkService: NetworkService
    private var coinList: [Coin] = []
    var delegate: CoinListDataManagerDelegate?
    var coinSortAction: CoinSortAction? {
        didSet {
            delegate?.coinListDataManagerDidSetCoinSortAction()
        }
    }
    
    // MARK: - Init
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
}

// MARK: - Data Processing

extension CoinListDataManager {
    func sortedCoinList() -> [Coin] {
        guard let coinSortAction = coinSortAction else {
            return coinList.sorted {
                let first = $0.popularity ?? -Double.greatestFiniteMagnitude
                let second = $1.popularity ?? -Double.greatestFiniteMagnitude
                return first > second
            }
        }
        return coinList.sorted(by: coinSortAction)
    }
}

// MARK: - Networking

extension CoinListDataManager {
    func fetchCoinList() {
        networkService.request(api: TickerAPI()) { [weak self] result in
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
                    popularity: Double(tickerData.accTradeValue24Hour)
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
                        guard response.status == self?.successStatusCode else { return }
                        if let firstItem = response.transaction.first {
                            self?.coinList[i].currentPrice = Double(firstItem.price)
                            serialQueue.async {
                                count += 1
                                if count == self?.coinList.count {
                                    self?.delegate?.coinListDataManagerDidFetchCurrentPrice()
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

