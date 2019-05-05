//
//  ExerciseDetailViewController.swift
//  Fitcord
//
//  Created by Van Le on 1/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit

class ExerciseDetailViewController: UIViewController {
    
    var exercise: Exercise!

    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // View Controller LifeCycle.
    override func viewDidAppear(_ animated: Bool) {
        if exercise != nil {
            
            let image = UIImage(named: exercise.image!)
            self.navigationItem.title = exercise.name
            exerciseImage.image = image?.resizeImage(CGSize(width: 300.0, height: 300.0))
            descTextView.text = exercise.desc
        }
    }


}
