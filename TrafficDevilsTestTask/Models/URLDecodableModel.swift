//
//  URLDecodableModel.swift
//  TrafficDevilsTestTask
//
//  Created by Prokopenko Aleksandr on 18.11.2023.
//

import Foundation

protocol URLDecodableModel: Decodable {
    static var urlString: String { get }
}
