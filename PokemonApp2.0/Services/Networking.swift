//
//  Networking.swift
//  PokemonApp
//
//  Created by Mac on 11/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

enum NetworkError:Error{
    case URLDoesNotConnect
    case NoData
    case NoImage
}

class Networking{
    static let imageRootURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
    static let pokemonAPIRootURL = "https://pokeapi.co/api/v2/pokemon/?limit=151&offset=0"
    
    class func callAPI(_ url:URL,_ type:PokemonListType, completion:@escaping(Any?, Error?)->()){
        
        
        //        let returnVal = parseType(d, type)
        //        completion(returnVal, nil)
        
        let session = URLSession.shared
        
        session.dataTask(with: url){
            (data, response, error) in
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard let data = data else{
                completion(nil, NetworkError.NoData)
                return
            }
            
            let returnVal = parseType(data, type)
            
            completion(returnVal, nil)
            
            }.resume()
        
        
        
    }
    
    private static func parseType(_ data:Data,_ type:PokemonListType)->Any?{
        do{
            switch type {
            case .root:
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let dict = json as? [String:Any] else {return nil}
                guard let results = dict["results"] as? [[String:Any]] else {return nil}
                
                let pokemon:[PokemonBasic] = results.flatMap{
                    guard let name = $0["name"] as? String else {return nil}
                    guard let url = $0["url"] as? String else {return nil}
                    
                    return PokemonBasic(pokemonName: name, pokemonURL: url)
                }
                
                return pokemon
                
            case .type:
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let dict = json as? [String:Any] else{return nil}
                guard let outsidePokemon = dict["pokemon"] as? [[String:Any]] else{return nil}
                
                let pokemon:[PokemonBasic] = outsidePokemon.flatMap{
                    guard let insidePokemon = $0["pokemon"] as? [String:Any] else{return nil}
                    
                    guard let name = insidePokemon["name"] as? String else{return nil}
                    guard let url = insidePokemon["url"] as? String else{return nil}
                    
                    guard let val = URL(string: url)?.lastPathComponent else{return nil}
                    guard let v = Int(val) else{return nil}
                    guard v < 152 else{return nil}
                    
                    return PokemonBasic(pokemonName: name, pokemonURL: url)
                }
                
                return pokemon
                
            case .ability:
                
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let dict = json as? [String:Any] else{return nil}
                guard let outsidePokemon = dict["pokemon"] as? [[String:Any]] else{return nil}
                
                let pokemon:[PokemonBasic] = outsidePokemon.flatMap{
                    guard let insidePokemon = $0["pokemon"] as? [String:Any] else{return nil}
                    
                    guard let name = insidePokemon["name"] as? String else{return nil}
                    guard let url = insidePokemon["url"] as? String else{return nil}
                    
                    guard let val = URL(string: url)?.lastPathComponent else{return nil}
                    guard let v = Int(val) else{return nil}
                    guard v < 152 else{return nil}
                    
                    return PokemonBasic(pokemonName: name, pokemonURL: url)
                }
                
                return pokemon
                
            case .helditem:
                
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let dict = json as? [String:Any] else{return nil}
                guard let heldPokemon = dict["held_by_pokemon"] as? [[String:Any]] else{return nil}
                
                let pokemon:[PokemonBasic] = heldPokemon.flatMap{
                    guard let insidePokemon = $0["pokemon"] as? [String:Any] else{return nil}
                    
                    guard let name = insidePokemon["name"] as? String else{return nil}
                    guard let url = insidePokemon["url"] as? String else{return nil}
                    
                    guard let val = URL(string: url)?.lastPathComponent else{return nil}
                    guard let v = Int(val) else{return nil}
                    guard v < 152 else{return nil}
                    
                    return PokemonBasic(pokemonName: name, pokemonURL: url)
                }
                
                return pokemon
                
            default:
                
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let dict = json as? [String:Any] else{return nil}
                
                guard let name = dict["name"] as? String else{return nil}
                guard let id = dict["id"] as? Int else{return nil}
                guard let height = dict["height"] as? Int else{return nil}
                guard let weight = dict["weight"] as? Int else{return nil}
                
                guard let spriteDict = dict["sprites"] as? [String:Any] else{return nil}
                guard let frontDefault = spriteDict["front_default"] as? String else{return nil}
                guard let backDefault = spriteDict["back_default"] as? String else{return nil}
                guard let frontShiny = spriteDict["front_shiny"] as? String else{return nil}
                guard let backShiny = spriteDict["back_shiny"] as? String else{return nil}
                
                let sprites = [frontDefault, backDefault, frontShiny, backShiny]
                
                guard let moveArr = dict["moves"] as? [[String:Any]] else{return nil}
                let moves:[String] = moveArr.flatMap{
                    guard let mov = $0["move"] as? [String:Any] else{return nil}
                    guard let name = mov["name"] as? String else{return nil}
                    
                    return name
                }
                
                guard let abilityArr = dict["abilities"] as? [[String:Any]] else{return nil}
                let abilities:[Ability] = abilityArr.flatMap{
                    guard let ability = $0["ability"] as? [String:Any] else{return nil}
                    guard let name = ability["name"] as? String else{return nil}
                    guard let url = ability["url"] as? String else{return nil}
                    
                    return Ability(name: name, url: url)
                }
                
                guard let helditemArr = dict["held_items"] as? [[String:Any]] else{return nil}
                let heldItems:[HeldItem] = helditemArr.flatMap{
                    guard let item = $0["item"] as? [String:Any] else{return nil}
                    guard let name = item["name"] as? String else{return nil}
                    guard let url = item["url"] as? String else{return nil}
                    
                    return HeldItem(name: name, url:url)
                }
                
                guard let typeArr = dict["types"] as? [[String:Any]] else{return nil}
                let types:[Type] = typeArr.flatMap{
                    guard let type = $0["type"] as? [String:Any] else{return nil}
                    guard let name = type["name"] as? String else{return nil}
                    guard let url = type["url"] as? String else{return nil}
                    
                    return Type(name: name, url: url)
                }
                
                return PokemonDetailed(name: name, id: id, height: height, weight: weight, moves: moves, sprites: sprites, abilities: abilities, heldItems: heldItems, types: types)
            }
            
            
            
        } catch let error {
            print("My bad! I fucked up! \(error.localizedDescription)")
        }
        
        return nil
    }
    
    
}

