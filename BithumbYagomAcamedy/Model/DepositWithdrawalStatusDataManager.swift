//
//  DepositWithdrawalStatusDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/28.
//

import Foundation

protocol DepositWithdrawalStatusDataManagerDelegate {
    func depositWithdrawalStatusDataManagerDidSetData(_ statuses: [AssetsStatus])
}

final class DepositWithdrawalStatusDataManager {
    
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
    
    var delegate: DepositWithdrawalStatusDataManagerDelegate?
    
    init(service: HTTPNetworkService = HTTPNetworkService()) {
        self.service = service
        statuses = []
        filteredStatuses = []
    }
    
    func requestData() {
        let assetStatusAPI = AssetsStatusAPI()
        
        service.request(api: assetStatusAPI) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let data):
                let parsedData = self.parseAssetsStatuses(to: data)
                
                self.statuses = parsedData
                self.delegate?.depositWithdrawalStatusDataManagerDidSetData(parsedData)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func containedStatuses(in searchText: String) {
        if searchText.isEmpty {
            delegate?.depositWithdrawalStatusDataManagerDidSetData(statuses)
        } else {
            let containedData = statuses.filter {
                $0.coinName.contains(searchText) || $0.coinSymbol.contains(searchText)
            }
            
            delegate?.depositWithdrawalStatusDataManagerDidSetData(containedData)
        }
    }
    
    func filteredStatuses(by type: FilterType?) {
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
                    $0.isValidDeposit == false && $1.isValidDeposit == true
                }
            } else {
                sortedData = filteredStatuses.sorted {
                    $0.isValidDeposit == true && $1.isValidDeposit == false
                }
            }
        case .withdrawal:
            if isAscend {
                sortedData = filteredStatuses.sorted {
                    $0.isValidWithdrawal == false && $1.isValidWithdrawal == true
                }
            } else {
                sortedData = filteredStatuses.sorted {
                    $0.isValidWithdrawal == true && $1.isValidWithdrawal == false
                }
            }
        default:
            break
        }
        
        delegate?.depositWithdrawalStatusDataManagerDidSetData(sortedData)
    }
    
    private func parseAssetsStatuses(to data: Data) -> [AssetsStatus] {
        do {
            let parser = JSONParser()
            let assetsStatusesValueObject = try parser.decode(
                data: data, type: AssetsStatusValueObject.self
            )
            
            return createAssetsStatuses(to: assetsStatusesValueObject)
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    private func createAssetsStatuses(to valueObject: AssetsStatusValueObject) -> [AssetsStatus] {
        var result: [AssetsStatus] = []
        
        for (key, value) in valueObject.assetstatus {
            result.append(createAssetStatus(key, value))
        }
        
        return result
    }
    
    private func createAssetStatus(_ key: String, _ value: AssetStatusData) -> AssetsStatus {
        let depositStatus = isValidAssetStatus(to: value.depositStatus)
        let withdrawalStatus = isValidAssetStatus(to: value.withdrawalStatus)
        let depositStatusString = assetStatusString(by: depositStatus)
        let withdrawalStatusString = assetStatusString(by: withdrawalStatus)
        
        return AssetsStatus(
            coinName: key,
            coinSymbol: key,
            depositStatus: depositStatusString,
            withdrawalStatus: withdrawalStatusString,
            isValidDeposit: depositStatus,
            isValidWithdrawal: withdrawalStatus
        )
    }
    
    private func isValidAssetStatus(to status: Int) -> Bool {
        return status == Int.zero ? false : true
    }
    
    private func assetStatusString(by status: Bool) -> String {
        return status ? "정상" : "중단"
    }
}
