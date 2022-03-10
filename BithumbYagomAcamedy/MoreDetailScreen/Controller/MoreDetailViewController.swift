//
//  MoreDetailViewController.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import UIKit

class MoreDetailViewController: UIViewController {
    @IBOutlet private weak var userInfoStackView: UIStackView!
    @IBOutlet private weak var licenseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInfoStackView()
        configureLicenseTextView()
    }
    
    private func configureUserInfoStackView() {
        let nibName = UINib(nibName: "UserInfoView", bundle: nil)
        
        UserInformation.team.forEach { info in
            guard let view = nibName.instantiate(
                withOwner: self,
                options: nil
            ).first as? UserInfoView else {
                return
            }
            
            view.update(userInfo: info)
            userInfoStackView.addArrangedSubview(view)
        }
    }
    
    private func configureLicenseTextView() {
        licenseTextView.text = Lisence.apache
    }
}
