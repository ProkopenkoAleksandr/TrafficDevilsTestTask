//
//  DataManager.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 18.11.2023.
//

import Foundation

class TrafficDevilsDataService: TrafficDevilsServiceDelegate {
    
    static let shared = TrafficDevilsDataService()
    
    let apiService = TrafficDevilsService()

    init() {
        apiService.delegate = self
    }

    func endGameFetchData() {
        apiService.fetchData(for: GameResult.self)
    }

    func didReceiveData<T>(_ data: T) where T : Decodable {
        if let gameResult = data as? GameResult {
            if let winner = gameResult.winner {
                UserDefaults.standard.setValue("\(winner)", forKey: "winner")
            }
            if let loser = gameResult.loser {
                UserDefaults.standard.setValue("\(loser)", forKey: "loser")
            }
        }
    }

    func didFail(with error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
