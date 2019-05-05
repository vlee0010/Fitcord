//
//  CreateExerciseViewController.swift
//  Fitcord
//
//  Created by Van Le on 2/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit

class CreateExerciseViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    var updateTaskClosure:((Exercise) -> ())?
    
    var task: Exercise?
    
    weak var databaseController: DatabaseProtocol?
  
    let groupPicker = UIPickerView()
    var group = ["Chest", "Arms", "Back", "Legs", "Shoulder"]

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var muscleGroupTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    
          
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        showGroupPicker()
        
        //Hide keyboard
        nameTextField.delegate = self
        muscleGroupTextField.delegate = self
        descTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func saveExercise(_ sender: Any) {
        
        if nameTextField.text != "" && muscleGroupTextField.text != "" {
            
            // Convert user input to type String
            let exerciseName = nameTextField.text!
            let exerciseDesc = descTextField.text!
            let exerciseMuscleGroup = muscleGroupTextField.text!
          
        
                let _ = databaseController!.addExercise(name: exerciseName, desc: exerciseDesc, image: "defaultImage", muscleGroup: exerciseMuscleGroup)
            
            
            // Inform the task has been saved successfully
            let message = "Your exercise has been added"
            let alertController = UIAlertController(title: "Successfully Added", message: message,
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style:
                UIAlertAction.Style.default,handler: { action in
                    self.navigationController?.popViewController(animated: true)
                    return
            }))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // input validation. title and date are a must
        var errorMsg = "Please ensure all fields are filled:\n"
        
        if nameTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if descTextField.text == "" {
            errorMsg += "- Must provide muscle group\n"
        }
        
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    
    //show the status picker Completed/Not Completed
    func showGroupPicker() {
        groupPicker.delegate = self
        groupPicker.dataSource = self
        
        muscleGroupTextField.inputView = groupPicker
    }
    
    
    //message response
    func displayMessage(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return group.count
    }
    
    // set text for the group picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        muscleGroupTextField.text = group[row]
        self.view.endEditing(true)
    }
    
    // elements for picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return group[row]
    }

}
