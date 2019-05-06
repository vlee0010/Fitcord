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
    case routine
    case exercises
    case all
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExerciseListChange(change: DatabaseChange, exercises: [Exercise])
    func onRoutineListChange(change: DatabaseChange, routineExercises: [Exercise])
}
protocol DatabaseProtocol: AnyObject {
    var defaultRoutine: Routine {get}
    
    func addExercise(name: String, desc: String, image: String, muscleGroup: String) -> Exercise
    func updateExercise(name: String, desc: String, image: String, muscleGroup: String, exercise: Exercise) -> Exercise
    func deleteExercise(exercise: Exercise)
    
    func addRoutine(routineName: String) -> Routine
    func addExerciseToRoutine(exercise: Exercise, routine: Routine) -> Bool
    func deleteRoutine(routine: Routine)
    func removeExerciseFromRoutine(exercise: Exercise, routine: Routine)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
