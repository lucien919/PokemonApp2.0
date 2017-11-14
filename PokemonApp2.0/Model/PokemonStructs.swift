//
//  PokemonList.swift
//  PokemonApp
//
//  Created by Mac on 11/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

struct PokemonList{
    var results:[PokemonBasic]?
}

struct PokemonBasic {
    var pokemonName:String
    var pokemonURL:String
}

struct PokemonDetailed {
    var name:String
    var id:Int
    var height:Int
    var weight:Int
    
    var moves:[String]?
    var sprites:[String]?
    
    var abilities:[Ability]?
    var heldItems:[HeldItem]?
    var types:[Type]?
}

struct Ability {
    var name:String
    var url:String
}

struct Type {
    var name:String
    var url:String
}

struct HeldItem {
    var name:String
    var url:String
}






