//
//  NetworkService.swift
//  BithumbYagomAcamedy
//
//  Created by 황제하 on 2022/02/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case statusCodeError(_ statusCode: Int)
    case invalidURLRequest
    case unknown(error: Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "정상적인 Response가 아닙니다."
        case .statusCodeError(let statusCode):
            return "\(statusCode) Error: 정상적인 StatusCode가 아닙니다."
        case .invalidURLRequest:
            return "정상적인 URLRequest가 아닙니다."
        case .unknown(let error):
            return "\(error.localizedDescription) 에러가 발생했습니다."
        }
    }
}

struct HTTPNetworkService {
    private let session: URLSessionProviding
    
    init(session: URLSessionProviding = URLSession.shared) {
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard successStatusCode.contains(httpResponse.statusCode) else {
                completionHandler(
                    .failure(.statusCodeError(httpResponse.statusCode))
                )
                return
            }
            
            if let data = data {
                completionHandler(.success(data))
                return
            }
        }
        task.resume()
    }
    
    func request(
        api: APIable,
        completionHandler: @escaping ((Result<Data, NetworkError>) -> Void)
    ) {
        guard let urlRequest = URLRequest(api: api) else {
            completionHandler(.failure(.invalidURLRequest))
            return
        }
        loadData(urlRequest: urlRequest, completionHandler: completionHandler)
    }
}
