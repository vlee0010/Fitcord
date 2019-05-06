//
//  RoutinesTableViewController
//  Fitcord
//
//  Created by Van Le on 5/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit

class RoutinesTableViewController: UITableViewController, DatabaseListener, AddExerciseDelegate {
    
    let SECTION_ROUTINE = 0;
    let CELL_ROUTINE = "exerciseCell"
    
    var currentRoutine: [Exercise] = []
    weak var databaseController: DatabaseProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int {
        if section == SECTION_ROUTINE {
            return currentRoutine.count
        } else {
            return 1
        }
    }
    
    var listenerType = ListenerType.routine
    
    func onRoutineListChange(change: DatabaseChange, routineExercises: [Exercise]) {
        currentRoutine = routineExercises
        tableView.reloadData();
    }
    
    func onExerciseListChange(change: DatabaseChange, exercises: [Exercise]) {
        // wont' be called.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let partyCell = tableView.dequeueReusableCell(withIdentifier: CELL_ROUTINE,
                                                      for: indexPath)
            as! ExerciseTableViewCell
        let exercise = currentRoutine[indexPath.row]
        
        let image = UIImage(named: exercise.image!)
        partyCell.imageView?.image = image?.resizeImage(CGSize(width: 30.0, height: 30.0))
        
        partyCell.nameLabel.text = exercise.name
        partyCell.muscleGroupLabel.text = exercise.muscleGroup
        
        return partyCell
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath:
        IndexPath) -> Bool {
        if indexPath.section == SECTION_ROUTINE {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_ROUTINE {
            databaseController.removeExerciseFromRoutine(exercise: currentRoutine[indexPath.row], routine: databaseController.defaultRoutine)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addExerciseSegue") {
            let destination = segue.destination as! ExercisesListTableViewController
            destination.exerciseDelegate = self
        }
    }
    
    
    func addExercise(newExercise: Exercise) -> Bool {
        let result = databaseController.addExerciseToRoutine(exercise: newExercise, routine: databaseController.defaultRoutine)
        return result
    }
    
}
