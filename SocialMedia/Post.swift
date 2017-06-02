//
//  Post.swift
//  SocialMedia
//
//  Created by Ben on 5/30/17.
//  Copyright © 2017 Ben. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imgURL: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef :FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imgURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imgURL: String, likes: Int) {
        self._caption = caption
        self._imgURL = imgURL
        self._likes = likes
    }
    
    
    // This is what I use to convert data from firebase into something I can use.
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imgURL = postData["imageUrl"] as? String{
            self._imgURL = imgURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DataService.ds.REF_POST.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
}
