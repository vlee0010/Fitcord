//
//  AddExerciseDelegate.swift
//  Fitcord
//
//  Created by Van Le on 5/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import Foundation

protocol AddExerciseDelegate: AnyObject {
    func addExercise(newExercise: Exercise) -> Bool
}
