//
//  AuthenticationViewController.swift
//  Fitcord
//
//  Created by Van Le on 4/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit
import Firebase

class AuthenticationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}
