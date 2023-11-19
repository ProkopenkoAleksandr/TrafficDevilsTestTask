//
//  GameResult.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 18.11.2023.
//

import Foundation

struct GameResult: URLDecodableModel {
    let winner: URL?
    let loser: URL?

    static var urlString: String {
        return "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod"
    }
}
