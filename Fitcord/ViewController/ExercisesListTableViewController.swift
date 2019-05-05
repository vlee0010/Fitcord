//
//  ExercisesListTableViewController.swift
//  Fitcord
//
//  Created by Van Le on 30/4/19.
//  Copyright © 2019 Van Le. All rights reserved.
//


import UIKit


class ExercisesListTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener{
    
    let SECTION_EXERCISES = 0;
    let SECTION_COUNT = 1;
    let CELL_EXERCISE = "exerciseCell"
    
    var allExerises: [Exercise] = []
    var filteredExercises: [Exercise] = []
   
    weak var databaseController: DatabaseProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredExercises = allExerises
        
        // Search Exercise
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exercises"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // update search result for different screen
    //
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 {
            filteredExercises = allExerises.filter({(exercise: Exercise) -> Bool in
                return exercise.name!.lowercased().contains(searchText)
            })
        }
        else {
            filteredExercises = allExerises;
        }
        
        tableView.reloadData();
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_EXERCISES {
            return filteredExercises.count
        }
        else {
            return 1
        }
    }
    
    
    // display the cell with the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let exerciseCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXERCISE, for: indexPath) as! ExerciseTableViewCell
            let exercise = filteredExercises[indexPath.row]
            
            let image = UIImage(named: exercise.image!)
            exerciseCell.imageView?.image = image?.resizeImage(CGSize(width: 30.0, height: 30.0))
        
            exerciseCell.nameLabel.text =  exercise.name!
            exerciseCell.muscleGroupLabel.text = exercise.muscleGroup!
            
            return exerciseCell

    }
    
    // row can be edit
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_EXERCISES {
            return true
        }
        return false
    }
    
    // delete the exercise from the database.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_EXERCISES {
            let deletedExercise = filteredExercises[indexPath.row]
            self.filteredExercises.remove(at: indexPath.row)
            databaseController.deleteExercise(exercise: deletedExercise)
            
            
        }
    }
    
    // This function activate the swipe action. Swipe right to Mark the Task as Done
    // Can only be used for To Do screen, and not available in Completed task screen
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
////        if (isToDoScreen()){
////            let markAsCompletedAction = UIContextualAction(style: .normal, title:  "Mark as Done ", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
////                print("Marked as Done")
////                success(true)
////                let targetExercise = self.filteredExercises[indexPath.row]
////                targetExercise.status = "Completed"
////            })
////
////            markAsCompletedAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
////
////            return UISwipeActionsConfiguration(actions: [markAsCompletedAction])
////        }
////        else {
////            return UISwipeActionsConfiguration(actions: [])
////        }
//    }
    
    // When clicking a specific exercise cell, the exercose Detail will link to ExerciseDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "exerciseDetailSegue" {
            let controller: ExerciseDetailViewController = segue.destination as! ExerciseDetailViewController

            let selectedIndexPath = tableView.indexPathsForSelectedRows?.first
            controller.exercise = filteredExercises[selectedIndexPath!.row]
        }
    }
    
    var listenerType = ListenerType.exercises
    
    // Divide the task into 2 array for displaying: notCompleted and Completed
    // this function is called when the list is changed
    func onExerciseListChange(change: DatabaseChange, exercises: [Exercise]) {
        allExerises = exercises
        
        updateSearchResults(for: navigationItem.searchController!)
        
//        //set the badge for the first item in the tab bar. Inform how many tasks are not completed
//        tabBarController?.tabBar.items?.first?.badgeValue = notcompleted.count > 0 ? "\(notcompleted.count)" : nil
        
    }
    
    // display the message
    func displayMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension UIImage {
    func resizeImage(_ newSize: CGSize) -> UIImage? {
        func isSameSize(_ newSize: CGSize) -> Bool {
            return size == newSize
        }
        
        func scaleImage(_ newSize: CGSize) -> UIImage? {
            func getScaledRect(_ newSize: CGSize) -> CGRect {
                let ratio   = max(newSize.width / size.width, newSize.height / size.height)
                let width   = size.width * ratio
                let height  = size.height * ratio
                return CGRect(x: 0, y: 0, width: width, height: height)
            }
            
            func _scaleImage(_ scaledRect: CGRect) -> UIImage? {
                UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
                draw(in: scaledRect)
                let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
                return image
            }
            return _scaleImage(getScaledRect(newSize))
        }
        
        return isSameSize(newSize) ? self : scaleImage(newSize)!
    }
}

