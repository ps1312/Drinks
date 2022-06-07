//
//  Models.swift
//  Drinks
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import Foundation

public protocol HTTPClient {
    func get(_ url: URL) async throws -> Data
}

public struct Drink: Equatable {
    public let id: Int
    public let name: String
    public let thumb: URL

    public init(id: Int, name: String, thumb: URL) {
        self.id = id
        self.name = name
        self.thumb = thumb
    }
}

