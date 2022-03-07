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
    
    var roundedQuantity: String {
        let digit: Double = pow(10, 5)
        let multipliedDouble = self * digit
        let roundedQuantity = multipliedDouble.rounded() / digit
          
        return String(format: "%.4f", roundedQuantity)
    }
    
    var changePriceString: String {
        let commaChangePrice = self.commaPrice
        
        if self > 0 {
            return "+" + commaChangePrice
        }
        
        return commaChangePrice
    }
    
    var changeRateString: String {
        if self > 0 {
            return "+" + String(self) + "%"
        }
        
        return String(self) + "%"
    }
}
