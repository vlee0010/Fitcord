//
//  RoutineCardsViewController.swift
//  Fitcord
//
//  Created by Van Le on 17/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit
import CardParts

class RoutineCardsViewController: CardsViewController, AddRoutineDelegate {
    weak var routineDelegate : AddRoutineDelegate?
    
    var cards: [CardPartsViewController] = [
        CustomRoutineCardsViewController(),
        CustomRoutineCardsViewController(),
        CustomRoutineCardsViewController()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comment out one of the CardPartViewController in the card Array to change cards and/or their order
        
        loadCards(cards: cards)
        
    }
    
    func addRoutine(newRoutine: CustomRoutineCardsViewController) -> Bool {
        cards.append(newRoutine)
        return true
    }

    @IBAction func addNewRoutine(_ sender: Any) {
        let newRoutineTest = CustomRoutineCardsViewController()
        if routineDelegate!.addRoutine(newRoutine: newRoutineTest){
            self.viewDidLoad()
            self.viewWillAppear(true)
            return
        }
        
    }
}
