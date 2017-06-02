//
//  CircleView.swift
//  SocialMedia
//
//  Created by Ben on 5/27/17.
//  Copyright © 2017 Ben. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
