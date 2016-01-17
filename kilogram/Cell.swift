//
//  Cell.swift
//  kilogram
//
//  Created by TeeDee on 05.01.16.
//  Copyright © 2016 TeeDee. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {


    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
}
