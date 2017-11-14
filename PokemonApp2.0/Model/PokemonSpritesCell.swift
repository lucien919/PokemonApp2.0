//
//  PokemonSpritesCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonSpritesCell: UITableViewCell {
    @IBOutlet weak var frontDef:UIImageView!
    @IBOutlet weak var backDef:UIImageView!
    @IBOutlet weak var frontShiny:UIImageView!
    @IBOutlet weak var backShiny:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonSpritesCell", bundle: nil)
    }
    
}

