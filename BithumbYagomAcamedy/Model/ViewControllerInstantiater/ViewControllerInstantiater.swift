//
//  ViewControllerInstantiator.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/08.
//

import Foundation
import UIKit

struct ViewControllerInstantiater {
    func instantiate(
        _ instantiateInformation: ViewControllerInstantiatable
    ) -> UIViewController {
        let storyboard = UIStoryboard(
            name: instantiateInformation.storyboardName,
            bundle: nil
        )
        let viewController = storyboard.instantiateViewController(
            withIdentifier: instantiateInformation.viewControllerName
        )
        
        return viewController
    }
}
