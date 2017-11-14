//
//  PokemonMoveCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonMoveCell: UITableViewCell {
    @IBOutlet weak var moveName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moveName.textColor = UIColor.cyan
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonMoveCell", bundle: nil)
    }
    
}

