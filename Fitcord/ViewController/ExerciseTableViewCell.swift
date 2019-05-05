//
//  ExerciseTableViewCell.swift
//  Fitcord
//
//  Created by Van Le on 1/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var muscleGroupLabel: UILabel!
   
    @IBOutlet weak var exerciseImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


