//
//  UserInfoView.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import UIKit

class UserInfoView: UIView {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userLinkLabel: UILabel!
    @IBOutlet private weak var userEmailLabel: UILabel!
    
    func update(userInfo: UserInformation) {
        userImageView.image = UIImage(named: userInfo.imageURL)
        userNameLabel.text = "\(userInfo.name) (\(userInfo.nickName))"
        userLinkLabel.text = userInfo.link
        userEmailLabel.text = userInfo.email
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
    }
}
