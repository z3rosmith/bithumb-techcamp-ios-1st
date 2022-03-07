//
//  Double+extension.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/03/07.
//

import Foundation

extension Double {
    var commaPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter.string(for: self) ?? "오류 발생"
    }
}
