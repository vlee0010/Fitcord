//
//  CoreDataController.swift
//  Fitcord
//
//  Created by Van Le on 30/4/19.
//  Copyright © 2019 Van Le. All rights reserved.
//


import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    let DEFAULT_ROUTINE_NAME = "Default Routine"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    var allExercisesFetchedResultsController: NSFetchedResultsController<Exercise>?
    var allRoutinesFetchedResultsController: NSFetchedResultsController<Exercise>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "Exercises")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        super.init()
        
        if fetchAllExercises().count == 0 {
            createDefaultEntries()
        }
        
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addExercise(name: String, desc: String, image: String, muscleGroup: String) -> Exercise {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise",
                                                       into: persistantContainer.viewContext) as! Exercise
        exercise.name = name
        exercise.desc = desc
        exercise.image = image
        exercise.muscleGroup = muscleGroup
        
        saveContext()
        return exercise
    }
    
    func addRoutine(routineName: String) -> Routine {
        let routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into:
            persistantContainer.viewContext) as! Routine
        routine.name = routineName

        saveContext()
        return routine
    }
    
    func addExerciseToRoutine(exercise: Exercise, routine: Routine) -> Bool {
        routine.addToExercises(exercise)
        saveContext()
        return true
    }
    
    func updateExercise(name: String, desc: String, image: String, muscleGroup: String, exercise: Exercise) -> Exercise {
        exercise.setValue(name, forKey: "name")
        exercise.setValue(desc, forKey: "desc")
        exercise.setValue(image, forKey: "image")
        exercise.setValue(muscleGroup, forKey: "muscleGroup")
        
        saveContext()
        return exercise
    }
    
    func deleteRoutine(routine: Routine) {
        persistantContainer.viewContext.delete(routine)
        saveContext()
    }
    
    func deleteExercise(exercise: Exercise) {
        persistantContainer.viewContext.delete(exercise)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func removeExerciseFromRoutine(exercise: Exercise, routine: Routine) {
        routine.removeFromExercises(exercise)
        saveContext()
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.exercises {
            listener.onExerciseListChange(change: .update, exercises: fetchAllExercises())
        }
        
        if listener.listenerType == ListenerType.routine || listener.listenerType ==
            ListenerType.all {
            listener.onRoutineListChange(change: .update, routineExercises: fetchAllRoutines())
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllExercises() -> [Exercise] {
        if allExercisesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allExercisesFetchedResultsController =
                NSFetchedResultsController<Exercise>(fetchRequest: fetchRequest,
                                                 managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                                                 cacheName: nil)
            allExercisesFetchedResultsController?.delegate = self
            do {
                try allExercisesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var exercises = [Exercise]()
        if allExercisesFetchedResultsController?.fetchedObjects != nil {
            exercises = (allExercisesFetchedResultsController?.fetchedObjects)!
        }
        
        return exercises
    }
    
    func fetchAllRoutines() -> [Exercise] {
        if allRoutinesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            let predicate = NSPredicate(format: "ANY routines.name == %@",
                                        DEFAULT_ROUTINE_NAME)
            fetchRequest.predicate = predicate
            allRoutinesFetchedResultsController =
                NSFetchedResultsController<Exercise>(fetchRequest: fetchRequest,
                                                      managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                                                      cacheName: nil)
            allRoutinesFetchedResultsController?.delegate = self
            
            do {
                try allRoutinesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var exercises = [Exercise]()
        if allRoutinesFetchedResultsController?.fetchedObjects != nil {
            exercises = (allRoutinesFetchedResultsController?.fetchedObjects)!
        }
        
        return exercises
    }
    
    
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allExercisesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.exercises {
                    listener.onExerciseListChange(change: .update, exercises: fetchAllExercises())
                }
            }
        }
        else if controller == allRoutinesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.routine ||
                    listener.listenerType == ListenerType.all {
                    listener.onRoutineListChange(change: .update, routineExercises: fetchAllRoutines())
                }
            }
        }
        
        
    }
    
    lazy var defaultRoutine: Routine = {
        var routines = [Routine]()
        
        let request: NSFetchRequest<Routine> = Routine.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_ROUTINE_NAME)
        request.predicate = predicate
        do {
            try routines = persistantContainer.viewContext.fetch(Routine.fetchRequest())
                as! [Routine]
        } catch {
            print("Fetch Request failed: \(error)")
        }
        
        if routines.count == 0 {
            return addRoutine(routineName: DEFAULT_ROUTINE_NAME)
        }
        else {
            return routines.first!
        }
    }()
    
    func createDefaultEntries() {
        let _ = addExercise(name: "Bench Press",
                            desc: "1. Lying on a bench, hold the barbell over the chest, arms straight, hands placed slightly outside of shoulder width. Keep your chest up at all time, and allow the lower back to maintain a natural arch (not excessive). Lower the barbell to the top of the chest. Press the bar back up to the top, until your arms are straight.",
                            image:"bench_press",
                            muscleGroup: "Chest, Triceps")
        
        let _ = addExercise(name: "Squat",
                            desc: "Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.",
                            image:"squat",
                            muscleGroup: "Legs")
        
        let _ = addExercise(name: "Deadlift",
                            desc: "Approach the bar so that it is centered over your feet. Your feet should be about hip-width apart. Bend at the hip to grip the bar at shoulder-width allowing your shoulder blades to protract. Typically, you would use an alternating grip. With your feet and your grip set, take a big breath and then lower your hips and flex the knees until your shins contact the bar. Look forward with your head. Keep your chest up and your back arched, and begin driving through the heels to move the weight upward. After the bar passes the knees aggressively pull the bar back, pulling your shoulder blades together as you drive your hips forward into the bar. Lower the bar by bending at the hips and guiding it to the floor.",
                            image:"deadlift",
                            muscleGroup: "Back")
        
        let _ = addExercise(name: "Overhead Press",
                            desc: "Stand with the bar on your front shoulders, and your hands next to your shoulders. Press the bar over your head, until it’s balanced over your shoulders and mid-foot. Lock your elbows at the top, and shrug your shoulders to the ceiling",
                            image:"overhead_press",
                            muscleGroup: "Shoulder")
        
        let _ = addExercise(name: "Barbell Row  ",
                            desc: "Stand with your mid-foot under the bar (medium stance). Bend over and grab the bar (palms down, medium-grip). Unlock your knees while keeping your hips high. Lift your chest and straighten your back. Pull the bar against your lower chest",
                            image:"barbell_row",
                            muscleGroup: "Back")
        
    }
    
    
}

