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

struct Drink {
    var id: Int
    var name: String
    var thumb: String
}

protocol DrinksLoader {}
