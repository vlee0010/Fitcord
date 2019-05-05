//
//  DatabaseProtocol.swift
//  Fitcord
//
//  Created by Van Le on 30/4/19.
//  Copyright © 2019 Van Le. All rights reserved.
//


import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    case exercises
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExerciseListChange(change: DatabaseChange, exercises: [Exercise])
}
protocol DatabaseProtocol: AnyObject {
    
    func addExercise(name: String, desc: String, image: String, muscleGroup: String) -> Exercise
    func updateExercise(name: String, desc: String, image: String, muscleGroup: String, exercise: Exercise) -> Exercise
    func deleteExercise(exercise: Exercise)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
