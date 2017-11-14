//
//  PokemonBasicInfoCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonBasicInfoCell: UITableViewCell {
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var idLabel:UILabel!
    @IBOutlet weak var heightLabel:UILabel!
    @IBOutlet weak var weightLAbel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.textColor = UIColor.cyan
        idLabel.textColor = UIColor.cyan
        heightLabel.textColor = UIColor.cyan
        weightLAbel.textColor = UIColor.cyan
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonBasicInfoCell", bundle: nil)
    }
    
}

