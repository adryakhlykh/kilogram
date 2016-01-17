//
//  LoginVC.swift
//  kilogram
//
//  Created by TeeDee on 17.01.16.
//  Copyright © 2016 TeeDee. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    let instagramService = InstagramService()
    
    @IBOutlet weak var img: UIImageView!
    @IBAction func auth(sender: AnyObject) {
        instagramService.authentication()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("base") 
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)
        
        
    }
}
