//
//  ProfileViewController.swift
//  Fitcord
//
//  Created by Van Le on 4/5/19.
//  Copyright © 2019 Van Le. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ProfileViewController: UIViewController {
    var imagePicker: UIImagePickerController!
    var currentUser = Auth.auth().currentUser!
    var username: String = ""
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        username = currentUser.displayName ?? "Username"
        usernameLabel.text = username
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
    
            let imageName = value?["profileImageUrl"] as? String ?? ""
            
            if imageName != "" {
            let imageUrl:URL = URL(string: imageName)!
            DispatchQueue.global(qos: .userInitiated).async {
                
                let imageData:NSData = NSData(contentsOf: imageUrl)!

                // When from background thread, UI needs to be updated on main_queue
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: imageData as Data)
                    self.makeRoundedImage()
                }
            }
            }}) { (error) in
            print(error.localizedDescription)
        }
        
        
      
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        self.makeRoundedImage()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func handleLogout(_ sender:Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func uploadProfileImage(imageData: Data)
    {
        
        let storageReference = Storage.storage().reference()
        
        let profileImageRef = storageReference.child("users").child(currentUser.uid).child("\(currentUser.uid)-profileImage.jpg")
        
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                
                self.profileImageView.image = UIImage(data: imageData)
                
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
            }
            profileImageRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let url = url else { return }
                let values = ["profileImageUrl": url.absoluteString]
                
                self.registerUserIntoDatabaseWithUID(self.currentUser.uid, values: values as [String : AnyObject])
            })
        }
        
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let profileImage = selectedImageFromPicker
        {
            self.profileImageView.image = profileImage
            makeRoundedImage()
            // upload image from here
            uploadProfileImage(imageData: profileImage.jpegData(compressionQuality:0.6)!)
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    func makeRoundedImage(){
        self.profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
    }

}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

