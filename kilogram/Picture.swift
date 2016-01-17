//
//  Picture.swift
//  kilogram
//
//  Created by TeeDee on 06.01.16.
//  Copyright © 2016 TeeDee. All rights reserved.
//

import UIKit

class Picture: UIViewController {
    
    var instagramService = InstagramService()
    var selectedImage:NSData!
    var avatarImageData:NSData!
    var username:String!
    var picID:String!
    var likesCount:String!
    var text:String!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var likesCountLabel: UILabel!
 
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var userView: UIView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    

    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)

        
        let width = UIScreen.mainScreen().bounds.size.width
        
        
        self.imageView.frame = CGRectMake(0,0, width, width)
        self.imageView.constraints
        self.imageView.image = UIImage(data: selectedImage)
        self.imageViewHeightConstraint.constant = width
        self.imageView.backgroundColor = UIColor.blueColor()

        self.avatarImage.image = UIImage(data: avatarImageData)
        self.usernameLabel.text = username
        self.likesCountLabel.text = likesCount
        if text == "<null>" {
            self.textView.text = ""
        } else {
            self.textView.text = text
        }
        
    }
    
    
}
