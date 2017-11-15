//
//  PokemonTypeCell.swift
//  PokemonApp
//
//  Created by Mac on 11/13/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class PokemonTypeCell: UITableViewCell {
    @IBOutlet weak var typeLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        typeLabel.textColor = UIColor.black
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib:UINib{
        return UINib(nibName: "PokemonTypeCell", bundle: nil)
    }
    
}

