//
//  CustomRoutineCardsViewController.swift
//  Fitcord
//
//  Created by Van Le on 17/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import Foundation
import CardParts
import RxCocoa
import RxSwift
import Firebase

class CustomRoutineCardsViewController:  CardPartsViewController, CardPartsLongPressGestureRecognizerDelegate{
    var routineID : String = ""
    var minimumPressDuration: CFTimeInterval = 0.0
    var ref = Database.database().reference()
    var currentUser = Auth.auth().currentUser!
    
    let cardPartTitleWithMenu = CardPartTitleView(type: .titleWithMenu)
    let viewModel = CardPartTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        cardPartTitleWithMenu.menuOptions = ["Start Workout", "View Routine"]
        setupCardParts([cardPartTitleWithMenu])

       
    }
    
    
    func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        guard let menuTitle = cardPartTitleWithMenu.menuTitle, let menuOptions = cardPartTitleWithMenu.menuOptions else { return }
        
        let alert = UIAlertController(title: menuTitle, message: nil, preferredStyle: .alert)
        
        var index = 0
        for menuItem in menuOptions {
            let menuIndex = index
            let action = UIAlertAction(title: menuItem, style: .default, handler: { [weak self] (action) in
                if let observer = self?.cardPartTitleWithMenu.menuOptionObserver {
                    observer(menuItem, menuIndex)
                }
            })
            alert.addAction(action)
            index += 1
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in self.deleteRoutine()
            alert.dismiss(animated: true, completion: nil)
            
        })
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
        cardPartTitleWithMenu.menuOptionObserver  = {[weak self] (title, index) in
            // Logic to determine which menu option was clicked
            // and how to respond
            
            if index == 0 {
                
                let alertController = UIAlertController(title: "Woohoo!", message: "Isn't that awesome!?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self?.present(alertController, animated: true, completion: nil)
                
            }
            
            if index == 1 { 
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "RoutinesTableVC") as! RoutinesTableViewController
                self?.navigationController?.pushViewController(resultViewController, animated: true)
            
        }
        
        
    }
 }
    
    func deleteRoutine()  {
        let uid = self.currentUser.uid
        print(routineID)
        self.ref.child("users").child(uid).child("routineCollection").child(routineID).removeValue{ error, _ in
            print(error)
            self.removeCard(id: self.routineID)
            }
            
        }
    func removeCard(id:String) {
        let routineController = RoutineCardsViewController()
        routineController.removeCard(id: self.routineID)
        
 0     }
}

class CardPartTableViewModel {
    
    let listData: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    init() {
        
        var tempData: [String] = []
        
        for i in 0...5 {
            
            tempData.append("This is cell #\(i)")
        }
        
        listData.accept(tempData)
    }
}
