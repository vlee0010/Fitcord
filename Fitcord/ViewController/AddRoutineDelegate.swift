//
//  AddRoutineDelegate.swift
//  Fitcord
//
//  Created by Van Le on 21/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import Foundation
protocol AddRoutineDelegate: AnyObject {
    func addRoutine(newRoutine: CustomRoutineCardsViewController) -> Bool
}
