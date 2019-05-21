//
//  BaseTabBarController.swift
//  Fitcord
//
//  Created by Van Le on 8/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }

}
