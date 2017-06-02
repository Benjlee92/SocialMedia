//
//  FeedVC.swift
//  SocialMedia
//
//  Created by Ben on 5/27/17.
//  Copyright © 2017 Ben. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POST.observe(.value, with: { (snapshot) in
            self.posts = []
            print(snapshot.value)
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("Ben: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
                
            } else {
                cell.configureCell(post: post)
                return cell
            }
            
        } else {
            return PostCell()
        }
    }

    @IBAction func addImagetapped(_ sender: Any) {
                present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("Ben: add valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != ""  else {
            print("Ben: Caption Must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("Ben: Image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                
                if error != nil {
                    print("Ben: unable to upload image to firebase Storage \(error)")
                } else {
                    print("Ben: Successfully uploaded image to firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    self.postToFirebase(imgUrl: downloadURL!)
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POST.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "Camera")
    }

}
