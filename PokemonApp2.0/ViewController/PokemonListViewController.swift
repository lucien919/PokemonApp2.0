//
//  ViewController.swift
//  PokemonApp
//
//  Created by Mac on 11/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class PokemonListViewController: UIViewController {
    @IBOutlet weak var pokemonListCollection:UICollectionView!
    @IBOutlet weak var fav:UIBarButtonItem!
    
    var favoritePokemon:[NSManagedObject] = []
    var loadFavs:Bool = false
    
    var pokemonListURL:String?
    var pokemonListType:PokemonListType?
    
    var pokemon:[PokemonBasic]?
    var operationQueue:OperationQueue = OperationQueue()
    
    var selectedPokemon:PokemonBasic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pokemonListCollection.delegate = self
        self.pokemonListCollection.dataSource = self
        
        getFavoritePokemon()
        
        guard let type = pokemonListType else{
            setup(Networking.pokemonAPIRootURL, PokemonListType.root)
            return
        }
        guard let url = pokemonListURL else{return}
        setup(url, type)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let v = segue.destination as? PokemonViewController else{return}
        
        
        v.pokemonURL = self.selectedPokemon?.pokemonURL
    }
    
    @IBAction func addFavoritePokemon(_ sender:AnyObject) {
        let alert = UIAlertController(title: "Add Pokemon", message: "Enter a name", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Save", style: .default) {
            [unowned self] (action) in
            guard let name = alert.textFields?.first?.text else {return}
            //            guard let lastName = alert.textFields?[1].text else {return}
            var url:String?
            self.pokemon?.forEach{
                if($0.pokemonName==name){
                    url = $0.pokemonURL
                }
            }
            
            guard let u = url else{return}
            
            let p = PokemonBasic(pokemonName: name, pokemonURL: u)
            //            if let number = alert.textFields?[2].text{
            //                guy.number = Int(number)
            //            }
            self.saveToCoreData(p)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "Example: pikachu (Remember no caps)"
        }
        //        alert.addTextField { (textField) in
        //            textField.placeholder = "Last Name"
        //        }
        //        alert.addTextField { (textField) in
        //            textField.placeholder = "Number (Optional)"
        //        }
        self.present(alert, animated: true)
    }
    
    @IBAction func changeList(_ sender:AnyObject){
        if(loadFavs){
            self.loadFavs = false
            self.fav.title = "favs"
        }else{
            self.loadFavs = true
            self.fav.title = "list"
        }
        self.pokemonListCollection.reloadData()
    }
    
}

typealias PokemonListCollectionFunctions = PokemonListViewController
extension PokemonListCollectionFunctions: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(loadFavs){
            return favoritePokemon.count
            
        }else{
            guard let count = pokemon?.count else{return 0}
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonListCell", for: indexPath) as? PokemonListCell else{fatalError("There is no cell")}

        cell.pokemonImageView.image = #imageLiteral(resourceName: "Default")
        cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        
        if(loadFavs){
            let mon = favoritePokemon[indexPath.row]
            
            guard let name = mon.value(forKeyPath: "name") as? String else {return cell}
            guard let url = mon.value(forKeyPath: "url") as? String else {return cell}
            
            cell.pokemonName.text = name
            cell.pokemonName.textColor = UIColor.cyan
            guard let val = URL(string: url)?.lastPathComponent else{return cell}
            cell.pokemonImageView.imageFrom(url: Networking.imageRootURL+"\(val).png", queue: operationQueue)
            
        }else{
            guard let mon = pokemon?[indexPath.row] else{return cell}
            
            cell.pokemonName.text = mon.pokemonName
            cell.pokemonName.textColor = UIColor.cyan
            guard let val = URL(string: mon.pokemonURL)?.lastPathComponent else{return cell}
            cell.pokemonImageView.imageFrom(url: Networking.imageRootURL+"\(val).png", queue: operationQueue)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        self.selectedPokemon = pokemon?[indexPath.item]
        performSegue(withIdentifier: "ToPokemonSegue", sender: self)
    }
    
}

typealias PokemonListOtherFunctions = PokemonListViewController
extension PokemonListOtherFunctions{
    
    func setup(_ url:String,_ type:PokemonListType){
        
        guard let url = URL(string: url) else{return}
        
        Networking.callAPI(url, type){
            (val, error) in
            guard error==nil else{return}
            guard let pokemonList = val as? [PokemonBasic] else{return}
            
            self.pokemon = pokemonList
            
            DispatchQueue.main.async {
                self.pokemonListCollection.reloadData()
            }
        }
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background"))
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        self.pokemonListCollection.backgroundView = imageView
    }
    
    private func saveToCoreData(_ p:PokemonBasic){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoritePokemon", in: managedContext) else {return}
        let poke = NSManagedObject(entity: entity, insertInto: managedContext)
        
        poke.setValue(p.pokemonName, forKey: "name")
        poke.setValue(p.pokemonURL, forKey: "url")
        
        
        do {
            try managedContext.save()
            favoritePokemon.append(poke)
            self.pokemonListCollection.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    private func getFavoritePokemon(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName:"FavoritePokemon")
        
        do {
            self.favoritePokemon = try managedContext.fetch(request)
            //self.pokemonListCollection.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
}











