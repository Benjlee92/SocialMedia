//
//  PostCell.swift
//  SocialMedia
//
//  Created by Ben on 5/27/17.
//  Copyright © 2017 Ben. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    var post: Post!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var numberOfLikes: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)

        self.caption.text = post.caption
        self.numberOfLikes.text = String(post.likes)
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: {(data, error) in
                
                if error != nil {
                    print("Ben: unable to download image from firebase storage: \(error)")
                } else {
                    print("Ben: Image downlaoded from firebase storage")
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Heart")
            } else {
                self.likeImg.image = UIImage(named: "HeartFilled")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "HeartFilled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "Heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }


}
