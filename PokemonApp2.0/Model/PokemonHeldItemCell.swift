//
//  PokemonHeldItemCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonHeldItemCell: UITableViewCell {
    @IBOutlet weak var heldItemLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        heldItemLabel.textColor = UIColor.cyan
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonHeldItemCell", bundle: nil)
    }
    
}

