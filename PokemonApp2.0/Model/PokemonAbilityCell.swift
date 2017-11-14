//
//  PokemonAbilityCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonAbilityCell: UITableViewCell {
    @IBOutlet weak var abilityName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        abilityName.textColor = UIColor.cyan
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonAbilityCell", bundle: nil)
    }
    
}

