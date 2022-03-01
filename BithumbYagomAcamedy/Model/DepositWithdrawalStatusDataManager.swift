//
//  DepositWithdrawalStatusDataManager.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/02/28.
//

import Foundation

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
    private(set) var statuses: [AssetsStatus]
    
    init(service: HTTPNetworkService = HTTPNetworkService()) {
        self.service = service
        statuses = []
    }
    
    func requestData(completion: @escaping ([AssetsStatus]) -> Void) {
        let assetStatusAPI = AssetsStatusAPI()
        
        service.request(api: assetStatusAPI) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let data):
                self.excuteResultSuccess(data: data, successHandler: completion)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func containStatuses(in searchText: String) -> [AssetsStatus] {
        return statuses.filter {
            $0.coinName.contains(searchText) || $0.coinSymbol.contains(searchText)
        }
    }
    
    func filterStatuses(by type: FilterType?) -> [AssetsStatus] {
        var filteredData: [AssetsStatus] = []
        
        switch type {
        case .all:
            filteredData = statuses
        case .normal:
            filteredData = statuses.filter { $0.isValidDeposit && $0.isValidWithdrawal }
        case .stop:
            filteredData = statuses.filter { !$0.isValidDeposit || !$0.isValidWithdrawal }
        default:
            break
        }
        
        return filteredData
    }
    
    func sortStatuses(data: [AssetsStatus], by type: SortType?, _ isAscend: Bool) -> [AssetsStatus] {
        var sortedData: [AssetsStatus] = []
        
        switch type {
        case .name:
            sortedData = isAscend ?
            data.sorted { $0.coinName > $1.coinName } :
            data.sorted { $0.coinName < $1.coinName }
        case .deposit:
            sortedData = isAscend ?
            data.sorted {
                $0.isValidDeposit == false && $1.isValidDeposit == true
            } :
            data.sorted {
                $0.isValidDeposit == true && $1.isValidDeposit == false
            }
        case .withdrawal:
            sortedData = isAscend ?
            data.sorted {
                $0.isValidWithdrawal == false && $1.isValidWithdrawal == true
            } :
            data.sorted {
                $0.isValidWithdrawal == true && $1.isValidWithdrawal == false
            }
        default:
            break
        }
        
        return sortedData
    }
    
    private func excuteResultSuccess(data: Data, successHandler: ([AssetsStatus]) -> Void) {
        do {
            let assetStatusValueObject = try self.parseAssetsStatusValueObject(to: data)
            let result = self.createAssetsStatuses(to: assetStatusValueObject)
            
            self.statuses.append(contentsOf: result)
            successHandler(self.statuses)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func parseAssetsStatusValueObject(to data: Data) throws -> AssetsStatusValueObject {
        do {
            let parser = JSONParser()
            let assetsStatuses = try parser.decode(data: data, type: AssetsStatusValueObject.self)
            
            return assetsStatuses
        } catch {
            print(error.localizedDescription)
            
            throw error
        }
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
