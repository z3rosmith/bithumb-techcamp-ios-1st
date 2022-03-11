//
//  UserInformation.swift
//  BithumbYagomAcamedy
//
//  Created by Oh Donggeon on 2022/03/10.
//

import Foundation

struct UserInformation {
    let imageURL: String
    let name: String
    let nickName: String
    let link: String
    let email: String
    
    static var team: [UserInformation] {
        let donggeonInfo = UserInformation(
            imageURL: "Donggeon",
            name: "오동건",
            nickName: "DonggeonOh",
            link: "https://github.com/DonggeonOh",
            email: "cafa3@naver.com"
        )
        let zeroInfo = UserInformation(
            imageURL: "Zero",
            name: "김진영",
            nickName: "제로",
            link: "https://github.com/z3rosmith",
            email: "zero0204@gmail.com"
        )
        let heohwangInfo = UserInformation(
            imageURL: "Jeha",
            name: "황제하",
            nickName: "허황",
            link: "https://github.com/HJEHA",
            email: "hyhpwang@gmail.com"
        )
        
        return [donggeonInfo, zeroInfo, heohwangInfo]
    }
}
