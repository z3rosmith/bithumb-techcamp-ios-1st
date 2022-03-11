//
//  NetworkFailAlertPresentable.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/10.
//

import UIKit

protocol NetworkFailAlertPresentable {
    func showFetchFailAlert(
        viewController: UIViewController?,
        changeInventoryActionCompletion: @escaping (UIAlertAction) -> Void
    )
}

extension NetworkFailAlertPresentable {
    func showFetchFailAlert(
        viewController: UIViewController?,
        retryActionCompletion: @escaping (UIAlertAction) -> Void
    ) {
        let noAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        let okAction = UIAlertAction(
            title: "재시도",
            style: .default,
            handler: retryActionCompletion
        )
        let alert = AlertFactory.create(
            title: "데이터를 가져오는데 실패했습니다",
            message: "재시도 하시겠습니까?",
            preferredStyle: .alert,
            actions: noAction, okAction
        )
        
        viewController?.present(alert, animated: true)
    }
}
