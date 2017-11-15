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
    
    var favoritePokemon:[NSManagedObject] = []
    var loadFavs:Bool = false
    
    var pokemonListURL:String?
    var pokemonListType:PokemonListType = PokemonListType.root
    
    var pokemon:[PokemonBasic]?
    var operationQueue:OperationQueue = OperationQueue()
    
    var selectedPokemon:PokemonBasic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pokemonListCollection.delegate = self
        self.pokemonListCollection.dataSource = self
        
        getFavoritePokemon()
        
        guard let url = pokemonListURL else{
            setup(Networking.pokemonAPIRootURL, pokemonListType)
            return
        }
        setup(url, pokemonListType)
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

            var url:String?
            self.pokemon?.forEach{
                if($0.pokemonName==name){
                    url = $0.pokemonURL
                }
            }
            
            guard let u = url else{return}
            
            let p = PokemonBasic(pokemonName: name, pokemonURL: u)
            
            self.saveToCoreData(p)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "Example: pikachu (Remember no caps)"
        }
        
        self.present(alert, animated: true)
    }
    
    @IBAction func removeFavoritePokemon(_ sender:AnyObject) {
        let alert = UIAlertController(title: "Remove Pokemon", message: "Enter a name", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Remove", style: .default) {
            [unowned self] (action) in
            guard let name = alert.textFields?.first?.text else {return}
            
            self.removeFromCoreData(name)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "Example: pikachu (Remember no caps)"
        }
        
        self.present(alert, animated: true)
    }
    
    @IBAction func changeToFavs(_ sender:AnyObject){
        loadFavs = true
        getFavoritePokemon()
        pokemonListCollection.reloadData()
    }
    
    @IBAction func changeToList(_ sender:AnyObject){
        loadFavs = false
        pokemonListCollection.reloadData()
    }
    
    @IBAction func display151(_ sender:AnyObject){
        setup(Networking.pokemonAPIRootURL, PokemonListType.root)
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
        cell.pokemonName.textColor = UIColor.cyan
        cell.backgroundView?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Gray-Background"))
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        
        if(loadFavs){
            let mon = favoritePokemon[indexPath.row]
            
            guard let name = mon.value(forKeyPath: "name") as? String else {return cell}
            guard let url = mon.value(forKeyPath: "url") as? String else {return cell}
            
            cell.pokemonName.text = name
            guard let val = URL(string: url)?.lastPathComponent else{return cell}
            cell.pokemonImageView.imageFrom(url: Networking.imageRootURL+"\(val).png", queue: operationQueue)
            
        }else{
            guard let mon = pokemon?[indexPath.row] else{return cell}
            
            cell.pokemonName.text = mon.pokemonName
            guard let val = URL(string: mon.pokemonURL)?.lastPathComponent else{return cell}
            cell.pokemonImageView.imageFrom(url: Networking.imageRootURL+"\(val).png", queue: operationQueue)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if(loadFavs){
            let mon = favoritePokemon[indexPath.row]
            
            guard let name = mon.value(forKey: "name") as? String else{return}
            guard let url = mon.value(forKey: "url") as? String else{return}
            
            self.selectedPokemon = PokemonBasic(pokemonName: name, pokemonURL: url)
        }else{
            self.selectedPokemon = pokemon?[indexPath.item]
        }
        
        performSegue(withIdentifier: "ToPokemonSegue", sender: self)
    }
    
}

typealias PokemonListOtherFunctions = PokemonListViewController
extension PokemonListOtherFunctions{
    
    func setup(_ url:String,_ type:PokemonListType){
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background"))
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        self.pokemonListCollection.backgroundView = imageView
        
        guard let url = URL(string: url) else{return}
        
        callNetwork(url, type)
        
    }
    
    private func callNetwork(_ url:URL,_ type:PokemonListType){
        Networking.callAPI(url, type){
            (val, error) in
            guard error==nil else{return}
            guard let pokemonList = val as? [PokemonBasic] else{return}
            
            self.pokemon = pokemonList
            
            DispatchQueue.main.async {
                self.pokemonListCollection.reloadData()
            }
        }
    }
    
    private func saveToCoreData(_ p:PokemonBasic){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoritePokemon", in: managedContext) else {return}
        let poke = NSManagedObject(entity: entity, insertInto: managedContext)
        
        poke.setValue(p.pokemonName, forKey: "name")
        poke.setValue(p.pokemonURL, forKey: "url")
        poke.setValue(LoginInfo.shared.user?.uid, forKey: "userKey")
        
        
        do {
            try managedContext.save()
            favoritePokemon.append(poke)
            self.pokemonListCollection.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    private func removeFromCoreData(_ n:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //var poke:NSManagedObject?
        favoritePokemon.forEach{
            guard let name = $0.value(forKey: "name") as? String else{return}
            if(n==name){
                managedContext.delete($0)
                //poke = $0
                if let index = favoritePokemon.index(of: $0){
                    favoritePokemon.remove(at: index)
                    self.pokemonListCollection.reloadData()
                }
                
            }
        }
        
        do{
            try managedContext.save()
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    private func getFavoritePokemon(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName:"FavoritePokemon")
        
        favoritePokemon.removeAll()
        
        do {
            let dummy = try managedContext.fetch(request)
            
            dummy.forEach{
                guard let key = $0.value(forKey: "userKey") as? String else{return}
                guard LoginInfo.shared.user?.uid==key else{return}
                self.favoritePokemon.append($0)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
}











