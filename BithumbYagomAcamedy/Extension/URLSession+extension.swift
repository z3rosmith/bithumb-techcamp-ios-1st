//
//  URLSession+extension.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }
