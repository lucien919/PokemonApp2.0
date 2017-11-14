//
//  PokemonViewController.swift
//  PokemonApp
//
//  Created by Mac on 11/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonViewController:UIViewController{
    @IBOutlet weak var pokemonTable:UITableView!
    
    var pokemonURL:String?
    
    var pokemon:PokemonDetailed?
    var operationQueue:OperationQueue = OperationQueue()
    
    var selectedPokemonList:String?
    var selectedPokemonListType:PokemonListType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pokemonTable.delegate = self
        self.pokemonTable.dataSource = self
        
        guard let url = pokemonURL else{return}
        setup(url)
        
        self.pokemonTable.register(PokemonBasicInfoCell.nib, forCellReuseIdentifier: "PokemonBasicInfoCell")
        self.pokemonTable.register(PokemonSpritesCell.nib, forCellReuseIdentifier: "PokemonSpritesCell")
        self.pokemonTable.register(PokemonTypeCell.nib, forCellReuseIdentifier: "PokemonTypeCell")
        self.pokemonTable.register(PokemonMoveCell.nib, forCellReuseIdentifier: "PokemonMoveCell")
        self.pokemonTable.register(PokemonAbilityCell.nib, forCellReuseIdentifier: "PokemonAbilityCell")
        self.pokemonTable.register(PokemonHeldItemCell.nib, forCellReuseIdentifier: "PokemonHeldItemCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let v = segue.destination as? PokemonListViewController else{return}
        
        v.pokemonListURL = self.selectedPokemonList
        v.pokemonListType = self.selectedPokemonListType
    }
    
}

typealias PokemonTableFunctions = PokemonViewController
extension PokemonTableFunctions: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaultVal = 0
        
        switch section {
        case 0:     //Basic info
            return 1
        case 1:     //Sprites
            return 1
        case 2:     //Types
            guard let count = self.pokemon?.types?.count else{return defaultVal}
            return count
        case 3:     //Moves
            guard let count = self.pokemon?.moves?.count else{return defaultVal}
            return count
        case 4:     //Abilities
            guard let count = self.pokemon?.abilities?.count else{return defaultVal}
            return count
        default:    //HeldItems
            guard let count = self.pokemon?.heldItems?.count else{return defaultVal}
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:     //Basic info
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonBasicInfoCell") as? PokemonBasicInfoCell else{fatalError("No Cell")}
            guard let pokemon = self.pokemon else{return cell}
            
            cell.pokemonImageView.image = #imageLiteral(resourceName: "Default")
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            guard let url = pokemon.sprites?.first else{return cell}
            cell.pokemonImageView.imageFrom(url: url, queue: operationQueue)
            
            cell.nameLabel.text = pokemon.name
            cell.idLabel.text = "\(pokemon.id)#"
            cell.heightLabel.text = "\(pokemon.height) hectograms"
            cell.weightLAbel.text = "\(pokemon.weight) decimeters"
            
            return cell
            
        //create xib for unique cell and set up here
        case 1:     //Sprites
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonSpritesCell") as? PokemonSpritesCell else{fatalError("No Cell")}
            
            cell.frontDef.image = #imageLiteral(resourceName: "Default")
            cell.backDef.image = #imageLiteral(resourceName: "Default")
            cell.frontShiny.image = #imageLiteral(resourceName: "Default")
            cell.backShiny.image = #imageLiteral(resourceName: "Default")
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            guard let sprites = self.pokemon?.sprites else{return cell}
            
            cell.frontDef.imageFrom(url: sprites[0], queue: operationQueue)
            cell.backDef.imageFrom(url: sprites[1], queue: operationQueue)
            cell.frontShiny.imageFrom(url: sprites[2], queue: operationQueue)
            cell.backShiny.imageFrom(url: sprites[3], queue: operationQueue)
            
            return cell
            
        case 2:     //Types
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonTypeCell") as? PokemonTypeCell else{fatalError("No Cell")}
            guard let types = self.pokemon?.types else{return cell}
            
            cell.typeLabel.text = types[indexPath.row].name
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            return cell
            
        case 3:     //Moves
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonMoveCell") as? PokemonMoveCell else{fatalError("No Cell")}
            guard let moves = self.pokemon?.moves else{return cell}
            
            cell.moveName.text = moves[indexPath.row]
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            return cell
            
        case 4:     //Abilities
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonAbilityCell") as? PokemonAbilityCell else{fatalError("No Cell")}
            guard let abilities = self.pokemon?.abilities else{return cell}
            
            cell.abilityName.text = abilities[indexPath.row].name
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            return cell
            
        default:    //HeldItems
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonHeldItemCell") as? PokemonHeldItemCell else{fatalError("No Cell")}
            guard let helditems = self.pokemon?.heldItems else{return cell}
            
            cell.heldItemLabel.text = helditems[indexPath.row].name
            
            cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
            
            return cell
        }
        
        //fatalError("Code should not get here ever. Cell creation failed")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic Info:"
        case 1:
            return "Sprites:"
        case 2:
            return "Type:"
        case 3:
            return "Moves:"
        case 4:
            return "Abilities:"
        default:
            return "Held Items:"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 2:     //types
            self.selectedPokemonList = self.pokemon?.types?[indexPath.row].url
            self.selectedPokemonListType = PokemonListType.type
        case 4:     //abilities
            self.selectedPokemonList = self.pokemon?.abilities?[indexPath.row].url
            self.selectedPokemonListType = PokemonListType.ability
        case 5:    //helditems
            self.selectedPokemonList = self.pokemon?.heldItems?[indexPath.row].url
            self.selectedPokemonListType = PokemonListType.helditem
        default:
            return
        }
        
        performSegue(withIdentifier: "ToPokemonListSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}


typealias PokemonOtherFunctions = PokemonViewController
extension PokemonOtherFunctions{
    
    func setup(_ url:String){
        
        guard let url = URL(string: url) else{return}
        
        Networking.callAPI(url, PokemonListType.detailpokemon){
            (val, error) in
            guard error==nil else{return}
            
            guard let pokemon = val as? PokemonDetailed else{return}
            self.pokemon = pokemon
            
            DispatchQueue.main.async {
                self.pokemonTable.reloadData()
            }
            
        }
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background"))
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        self.pokemonTable.backgroundView = imageView
        
    }
    
}











