//
//  DepositWithdrawalStatusDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/28.
//

import Foundation

protocol DepositWithdrawalStatusDataManagerDelegate: AnyObject {
    func depositWithdrawalStatusDataManagerDidSetData(_ statuses: [AssetsStatus])
    func depositWithdrawalStatusDataManagerDidFetchFail()
}

final class DepositWithdrawalStatusDataManager {
    
    // MARK: - Filter, Sort Enum
    
    enum FilterType: Int {
        case all
        case normal
        case stop
    }
    
    enum SortType {
        case name
        case deposit
        case withdrawal
    }
    
    // MARK: - Property
    
    private let service: HTTPNetworkService
    private var statuses: [AssetsStatus]
    private var filteredStatuses: [AssetsStatus]
    
    weak var delegate: DepositWithdrawalStatusDataManagerDelegate?
    
    // MARK: - Initializer
    
    init(service: HTTPNetworkService = HTTPNetworkService()) {
        self.service = service
        statuses = []
        filteredStatuses = []
    }
    
    // MARK: - Method
    
    func requestData() {
        let assetStatusAPI = AssetsStatusAPI()
        
        service.request(api: assetStatusAPI) { [weak self] result in
            guard let data = result.value else {
                self?.delegate?.depositWithdrawalStatusDataManagerDidFetchFail()
                print(result.error?.localizedDescription as Any)
                return
            }
            guard let parsedAssetsStatuses = try? self?.parseAssetsStatuses(to: data) else {
                return
            }
            let sortedAssetsStatuses = parsedAssetsStatuses.sorted {
                $0.coinName < $1.coinName
            }
            
            self?.statuses = sortedAssetsStatuses
            self?.filteredStatuses = sortedAssetsStatuses
            self?.delegate?.depositWithdrawalStatusDataManagerDidSetData(sortedAssetsStatuses)
        }
    }
    
    func filteredStatuses(by type: FilterType?, with searchText: String) {
        filteredStatuses = filteredStatuses(by: type)
        
        if searchText.isEmpty == false {
            let searchTextContainedStatuses = filteredStatuses.filter {
                return $0.coinName.localizedStandardContains(searchText) ||
                $0.coinSymbol.localizedStandardContains(searchText)
            }
            
            filteredStatuses = searchTextContainedStatuses
        }
        
        delegate?.depositWithdrawalStatusDataManagerDidSetData(filteredStatuses)
    }
    
    func sortedStatuses(by type: SortType?, _ isAscend: Bool) {
        var sortedData: [AssetsStatus] = []
        
        switch type {
        case .name:
            if isAscend {
                sortedData = filteredStatuses.sorted { $0.coinName < $1.coinName }
            } else {
                sortedData = filteredStatuses.sorted { $0.coinName > $1.coinName }
            }
        case .deposit:
            if isAscend {
                sortedData = filteredStatuses.sorted {
                    $0.isValidDeposit == true && $1.isValidDeposit == false
                }
            } else {
                sortedData = filteredStatuses.sorted {
                    $0.isValidDeposit == false && $1.isValidDeposit == true
                }
            }
        case .withdrawal:
            if isAscend {
                sortedData = filteredStatuses.sorted {
                    $0.isValidWithdrawal == true && $1.isValidWithdrawal == false
                }
            } else {
                sortedData = filteredStatuses.sorted {
                    $0.isValidWithdrawal == false && $1.isValidWithdrawal == true
                }
            }
        default:
            break
        }
        
        delegate?.depositWithdrawalStatusDataManagerDidSetData(sortedData)
    }
    
    private func filteredStatuses(by type: FilterType?) -> [AssetsStatus] {
        var filteredStatuses: [AssetsStatus] = []
        
        switch type {
        case .all:
            filteredStatuses = statuses
        case .normal:
            filteredStatuses = statuses.filter { $0.isValidDeposit && $0.isValidWithdrawal }
        case .stop:
            filteredStatuses = statuses.filter { !$0.isValidDeposit || !$0.isValidWithdrawal }
        default:
            break
        }
        
        return filteredStatuses
    }
    
    private func parseAssetsStatuses(to data: Data) throws -> [AssetsStatus] {
        do {
            let parser = JSONParser()
            let assetsStatusesValueObject = try parser.decode(
                data: data, type: AssetsStatusValueObject.self
            )
            
            return createAssetsStatuses(to: assetsStatusesValueObject)
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
    }
    
    private func createAssetsStatuses(to valueObject: AssetsStatusValueObject) -> [AssetsStatus] {
        var result: [AssetsStatus] = []
        
        for (key, value) in valueObject.assetstatus {
            let element = AssetsStatus(coinSymbol: key, assetStatusData: value)
            
            result.append(element)
        }
        
        return result
    }
}
