//
//  Models.swift
//  Drinks
//
//  Created by Paulo Sergio da Silva Rodrigues on 06/06/22.
//

import Foundation

// url: https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic
// "idDrink":"11007",
// "strDrink":"Margarita",
// "strDrinkThumb":"https:\/\/www.thecocktaildb.com\/images\/media\/drink\/5noda61589575158.jpg",

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

protocol DrinksLoader {}
