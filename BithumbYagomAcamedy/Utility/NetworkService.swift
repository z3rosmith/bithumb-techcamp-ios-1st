//
//  NetworkService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case statusCodeError
    case unknown(error: Error)

    var errorDescription: String? {
        switch self {
        case .statusCodeError:
            return "정상적인 StatusCode가 아닙니다."
        case .unknown(let error):
            return "\(error.localizedDescription) 에러가 발생했습니다."
        }
    }
}

struct NetworkService {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    private func loadData(
        urlRequest: URLRequest,
        completionHandler: @escaping ((Result<Data, NetworkError>) -> Void)
    ) {
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completionHandler(.failure(.unknown(error: error)))
                return
            }
            
            let successStatusCode = 200..<300
            
            guard let httpResponse = response as? HTTPURLResponse,
                  successStatusCode.contains(httpResponse.statusCode)
            else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            if let data = data {
                completionHandler(.success(data))
                return
            }
        }
        task.resume()
    }
}
