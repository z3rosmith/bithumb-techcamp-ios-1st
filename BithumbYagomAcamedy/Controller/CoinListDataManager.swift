//
//  CoinListDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

typealias CoinSortAction = (CoinListDataManager.Coin, CoinListDataManager.Coin) -> Bool

protocol CoinListDataManagerDelegate {
    func coinListDataManagerDidSetCoinList()
}

final class CoinListDataManager {
    
    typealias ValueObject = TickersValueObject
    
    // MARK: - Nested Type
    
    struct Coin: Hashable {
        let callingName: String
        let symbolName: String
        let currentPrice: Int
        let changeRate: Double
        let changePrice: Double
        let popularity: Double
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Coin, rhs: Coin) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    // MARK: - Property
    
    var delegate: CoinListDataManagerDelegate?
    private let networkService = NetworkService()
    private var coinList: [Coin] = []
}

// MARK: - Data Processing

extension CoinListDataManager {
    func sortedCoinList(by areInIncreasingOrder: CoinSortAction) -> [Coin] {
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
                    let response = try JSONParser().decode(data: data, type: ValueObject.self)
                    print(response.status)
                    if response.status == "0000" { // 상수 처리 의견 필요, 0000 외일 때는 어떻게 처리할지도..
                        self?.setCoinList(from: response)
                        self?.delegate?.coinListDataManagerDidSetCoinList()
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
    
    #warning("transaction history 최근가로 price 변경")
    private func setCoinList(from response: ValueObject) {
        response.ticker.forEach { key, dynamicValue in
            if let tickerData = dynamicValue.tickerData {
                let coin = Coin(
                    callingName: NSLocalizedString(key, comment: ""),
                    symbolName: key,
                    currentPrice: Int.random(in: 0...1000000), // 뭘로해야하지?
                    changeRate: tickerData.fluctateRate24HourDouble,
                    changePrice: tickerData.fluctate24HourDouble,
                    popularity: tickerData.accTradeValue24HourDouble
                )
                coinList.append(coin)
            }
        }
    }
}

// MARK: - CoinListDataManager.Coin Computed Property

extension CoinListDataManager.Coin {
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
