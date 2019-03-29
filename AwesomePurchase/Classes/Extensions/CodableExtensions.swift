//
//  CodableExtensions.swift
//  Zentra
//
//  Created by Evandro Harrison on 27/03/2019.
//  Copyright © 2019 It's Day Off. All rights reserved.
//

import Foundation

extension Encodable {
    func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
    
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> [Self] {
        return try decoder.decode([Self].self, from: data)
    }
}
