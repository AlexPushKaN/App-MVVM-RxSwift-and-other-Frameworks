//
//  NetworkManager.swift
//  App-MVVM-RxSwift-and-other-Frameworks
//
//  Created by Александр Муклинов on 28.07.2024.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkServiceDescription {
    var baseUrlString: String { get set }
    var callViewWithInfoNoConnect: PublishSubject<NetworkErrors> { get set }

    func requestFor(page: Int, completion: @escaping ([Any]?) -> Void)
    func isConnectedToNetwork() -> Bool
    func loadDataImage(from url: URL, completion: @escaping (Result<Data, AFError>) -> Void)
}

enum NetworkErrors: Error, Equatable {
    
    case noConnectToNetwork(String, String)
    case invalidResponse(String)
    case errorDecodingData
    case loadingImageData(Error)
    case failedRequest(String)

    static func == (lhs: NetworkErrors, rhs: NetworkErrors) -> Bool {
        switch (lhs, rhs) {
        case (.noConnectToNetwork, .noConnectToNetwork),
             (.errorDecodingData, .errorDecodingData):
            return true
        case let (.invalidResponse(lhsError), .invalidResponse(rhsError)):
            return lhsError == rhsError
        case let (.loadingImageData(lhsError), .loadingImageData(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.failedRequest(lhsMessage), .failedRequest(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

class NetworkManager: NetworkServiceDescription {
    
    var baseUrlString = "https://newsapi.org/v2/everything"
    var callViewWithInfoNoConnect = PublishSubject<NetworkErrors>()

    private let reachabilityManager = NetworkReachabilityManager()

    func requestFor(page: Int, completion: @escaping ([Any]?) -> Void) {
        
        guard isConnectedToNetwork() else {
            self.callViewWithInfoNoConnect.onNext(NetworkErrors.noConnectToNetwork("No connect to Internet", "Try update"))
            return
        }
        
        let parameters: [String: Any] = [
            "q": "ios",
            "from": "2019-04-00",
            "sortBy": "publishedAt",
            "apiKey": "26eddb253e7840f988aec61f2ece2907",
            "page": String(page)
        ]
        
        AF.request(baseUrlString, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let contentModel = try decoder.decode(ContentModel.self, from: data)
                    completion(contentModel.news)
                } catch {
                    print(NetworkErrors.errorDecodingData)
                    completion(nil)
                }
            case .failure(let error):
                if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
                    print(NetworkErrors.failedRequest("Failed request with status code \(statusCode)"))
                    completion(nil)
                } else {
                    print(NetworkErrors.invalidResponse(error.localizedDescription))
                    completion(nil)
                }
            }
        }
    }
    
    func loadDataImage(from url: URL, completion: @escaping (Result<Data, AFError>) -> Void) {
        AF.download(url).responseData { response in
            completion(response.result)
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
}

