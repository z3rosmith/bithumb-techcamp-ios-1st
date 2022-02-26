//
//  CoinListDataSource.swift
//  BithumbYagomAcamedy
//
//  Created by Jinyoung Kim on 2022/02/25.
//

import Foundation

protocol CoinListDataSourceDelegate {
    func didSetCoinList()
}

class CoinListDataSource {
    
    typealias ValueObject = TickersValueObject
    
    // MARK: - Nested Type
    
    struct Coin: Hashable {
        let callingName: String
        let symbolName: String
        let price: Int
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
    
    var delegate: CoinListDataSourceDelegate?
    private let networkService = NetworkService()
    private var coinList: [Coin] = []
}

// MARK: - Data Processing

extension CoinListDataSource {
    func sortedCoinList(by sortType: CoinSortType) -> [Coin] {
        let sortedCoinList: [Coin]
        switch sortType {
        case .popularityDescending(let descending):
            if descending {
                sortedCoinList = coinList.sorted { $0.popularity > $1.popularity }
            } else {
                sortedCoinList = coinList.sorted { $0.popularity < $1.popularity }
            }
        case .nameDescending(let descending):
            if descending {
                sortedCoinList = coinList.sorted { $0.callingName > $1.callingName }
            } else {
                sortedCoinList = coinList.sorted { $0.callingName < $1.callingName }
            }
        case .priceDescending(let descending):
            if descending {
                sortedCoinList = coinList.sorted { $0.price > $1.price }
            } else {
                sortedCoinList = coinList.sorted { $0.price < $1.price }
            }
        case .changeRateDescending(let descending):
            if descending {
                sortedCoinList = coinList.sorted { $0.changeRate > $1.changeRate }
            } else {
                sortedCoinList = coinList.sorted { $0.changeRate < $1.changeRate }
            }
        }
        return sortedCoinList
    }
}

// MARK: - Networking

extension CoinListDataSource {
    #warning("의견 필요 - 상수 처리")
    func fetchCoinList() {
        networkService.request(api: TickerAPI()) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONParser().decode(data: data, type: ValueObject.self)
                    print(response.status)
                    if response.status == "0000" { // 상수 처리 의견 필요
                        self?.setCoinList(from: response)
                        self?.delegate?.didSetCoinList()
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
    
    #warning("의견 필요 - 적절한 값으로 Coin생성했는지")
    private func setCoinList(from response: ValueObject) {
        response.ticker.forEach { key, dynamicValue in
            if let tickerData = dynamicValue.tickerData {
                let coin = Coin(
                    callingName: NSLocalizedString(key, comment: ""),
                    symbolName: key,
                    price: Int.random(in: 0...1000000), // 뭘로해야하지?
                    changeRate: tickerData.fluctateRate24HourDouble, // fluctateRate24Hour쓰는게 맞을지 의견 필요
                    changePrice: tickerData.fluctate24HourDouble, // fluctate24Hour쓰는게 맞을지 의견 필요
                    popularity: tickerData.accTradeValue24HourDouble // 이게 전날 24시간 거래금액 맞겠지?
                )
                coinList.append(coin)
            }
        }
    }
}

extension CoinListDataSource.Coin {
    var symbolPerKRW: String {
        return symbolName + "/KRW"
    }
    
    var priceString: String {
        return "\(price)"
    }
    
    var changeRateString: String {
        return "\(changeRate)"
    }
    
    var changePriceString: String {
        return "\(changePrice)"
    }
}

#warning("의견 필요 - 네이밍 의견")
/// 연관 값이 true인 경우 down(내림차순), false인 경우 up(오름차순)
enum CoinSortType {
    case popularityDescending(Bool)
    case nameDescending(Bool)
    case priceDescending(Bool)
    case changeRateDescending(Bool)
}
