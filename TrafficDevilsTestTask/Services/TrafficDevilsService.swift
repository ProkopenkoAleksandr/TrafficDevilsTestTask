//
//  APIService.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 18.11.2023.
//

import Foundation

protocol TrafficDevilsServiceDelegate: AnyObject {
    func didReceiveData<T: Decodable>(_ data: T)
    func didFail(with error: Error)
}

class TrafficDevilsService {
    weak var delegate: TrafficDevilsServiceDelegate?

    func fetchData<T: URLDecodableModel>(for type: T.Type) {
        guard let url = URL(string: T.urlString) else {
            delegate?.didFail(with: NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.delegate?.didFail(with: error)
                return
            }

            guard let data = data else {
                self.delegate?.didFail(with: NSError(domain: "No data received", code: 1, userInfo: nil))
                return
            }

            do {
                let jsonDecoder = JSONDecoder()
                let result = try jsonDecoder.decode(T.self, from: data)
                self.delegate?.didReceiveData(result)
            } catch let decodingError {
                self.delegate?.didFail(with: decodingError)
            }
        }
        .resume()
    }
}
