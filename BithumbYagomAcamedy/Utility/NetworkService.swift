//
//  NetworkService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

struct NetworkService {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
}
