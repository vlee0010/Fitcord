//
//  RoutineCardsViewController.swift
//  Fitcord
//
//  Created by Van Le on 17/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit
import CardParts
import Firebase

class RoutineCardsViewController: CardsViewController {
    var ref = Database.database().reference()
    var currentUser = Auth.auth().currentUser!
    var routineNameArray : [String] = []
    
    weak var routineDelegate : AddRoutineDelegate?
    
    var cards: [CustomRoutineCardsViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out one of the CardPartViewController in the card Array to change cards and/or their order
        let uid = currentUser.uid
        
        ref.child("users").child(uid).child("routineCollection").observeSingleEvent(of: .value, with: { (snapshot) in
           
            for child in snapshot.children{
                let userSnap = child as! DataSnapshot
                let dict = userSnap.value as! [String: String?]
            
                let routineName = dict["routineName"] as? String
                let id = dict["routineId"] as? String ?? ""
                print(dict)
                print(routineName, id)
                self.routineNameArray.append(routineName!)
                self.addNewCard(routineName: routineName!, id: id)
                print(self.cards)
            }
            self.loadCards(cards: self.cards)
        })
       
        self.loadCards(cards: self.cards)
        
    }

    @IBAction func addNewRoutine(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Routine", message: "Enter routine name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Routine Name"
            
        }
      
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let routineNameTextField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let uid = self.currentUser.uid
            
            guard let key = self.ref.child("users").child(uid).child("routineCollection").childByAutoId().key else {return}
            let routineRef = self.ref.child("users").child(uid).child("routineCollection").child(key)
            routineRef.setValue(["routineName": routineNameTextField?.text, "routineId": key])
            
            
            print(key)
            print("Text field: \(String(describing: routineNameTextField!.text))")
            self.addNewCard(routineName: routineNameTextField?.text ?? "Routine Name",id: key)
            self.loadCards(cards: self.cards)

        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addNewCard(routineName:String, id:String) {
        let newCard = CustomRoutineCardsViewController()
        newCard.cardPartTitleWithMenu.title = routineName
        newCard.cardPartTitleWithMenu.menuTitle = routineName
        newCard.routineID = id
        self.cards.append(newCard)
    }
    
    func removeCard(id:String) {
        if let index = self.cards.firstIndex(where: {$0.routineID == id}) {
            self.cards.remove(at: index)
        }
    }
}
