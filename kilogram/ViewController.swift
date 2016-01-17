//
//  ViewController.swift
//  kilogram
//
//  Created by TeeDee on 05.01.16.
//  Copyright © 2016 TeeDee. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource,InstagramServiceDelegate,UICollectionViewDelegate,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var instagramService = InstagramService()
    
    var userCoreData = [NSManagedObject]()
    var imageCoreData = [NSManagedObject]()
    var refreshControl = UIRefreshControl()
    var refreshString = "Загрузка"
    
    @IBAction func login(sender: AnyObject) {
        instagramService.quit()
        let vc = storyboard!.instantiateViewControllerWithIdentifier("login")
        self.presentViewController(vc, animated: true, completion: nil)
    }

   

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "load:", name: "load", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkInternet:", name: "checkInternet", object: nil)
        instagramService.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        instagramService.fetchData()
        
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "basebg")!)
        

        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: refreshString)
        
      
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refresh(sender:AnyObject){
        
        instagramService.loadMedia("refresh")
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()

        }
        NSNotificationCenter.defaultCenter().postNotificationName("checkInternet", object: nil)

        self.refreshControl.endRefreshing()

    
    }
    
  
    
    func userCoreData(userCoreData: [NSManagedObject]) {
        self.userCoreData = userCoreData
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()
        }
    }
  
    func  imageCoreData(imageCoreData: [NSManagedObject]) {
        self.imageCoreData  = imageCoreData
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()
        }
        
    }
   
  
    
    func load(notification: NSNotification) {
        instagramService.loadMedia("load")
    }
    
    func checkInternet(notification:NSNotification) {
        if self.instagramService.isConnectedToNetwork() == false {
            self.refreshString = "Нет интернета"
        } else {
            self.refreshString = "Загрузка"
        }
        self.refreshControl.attributedTitle = NSAttributedString(string: self.refreshString)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
            return imageCoreData.count
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Cell
        let width = UIScreen.mainScreen().bounds.size.width
        switch width {
        case 375:
           cell.imageViewHeightConstraint.constant = 177
           cell.imageViewWidthConstraint.constant = 177
        case 414:
            cell.imageViewHeightConstraint.constant = 196
            cell.imageViewWidthConstraint.constant = 196
        default:
            cell.imageViewHeightConstraint.constant = 150
            cell.imageViewWidthConstraint.constant = 150
            
        }

        
        let imgData = imageCoreData[indexPath.row].valueForKey("picURL") as? NSData
        cell.img.image = UIImage(data: imgData!)
        cell.likesLabel.text = imageCoreData[indexPath.row].valueForKey("likes") as? String
        cell.commentsLabel.text = imageCoreData[indexPath.row].valueForKey("comments") as? String
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let imageVC:Picture = self.storyboard?.instantiateViewControllerWithIdentifier("Picture") as! Picture
       
        
            imageVC.selectedImage = imageCoreData[indexPath.row].valueForKey("picURL") as? NSData
            imageVC.avatarImageData = userCoreData[indexPath.section].valueForKey("avatar") as? NSData
            imageVC.username = userCoreData[indexPath.section].valueForKey("username") as? String
            imageVC.picID = imageCoreData[indexPath.row].valueForKey("picID") as? String
            imageVC.likesCount = imageCoreData[indexPath.row].valueForKey("likes") as? String
            imageVC.text = imageCoreData[indexPath.row].valueForKey("text") as? String
            
            
        
        self.navigationController?.pushViewController(imageVC, animated: true)
        
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
            instagramService.loadMedia("scroll")
            collectionView.reloadData()
            
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
       
            
            if userCoreData.count < 2 {
                return userCoreData.count
            }
            else {
                return 1
            }
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! CollectionViewHeader
        
        
       
           
            let data = userCoreData[indexPath.section].valueForKey("avatar") as? NSData
            
            header.avatarImage.image = UIImage(data:data!)
            header.usernameLabel.text = userCoreData[indexPath.section].valueForKey("username") as? String
            header.fullNameLabel.text = userCoreData[indexPath.section].valueForKey("fullName") as? String
            header.mediaLabel.text = userCoreData[indexPath.section].valueForKey("media") as? String
            header.followsLabel.text = userCoreData[indexPath.section].valueForKey("follow") as? String
            header.followersLabel.text = userCoreData[indexPath.section].valueForKey("followers") as? String


        
        
        return header
       
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIScreen.mainScreen().bounds.size.width
        switch width {
            case 375:
                return CGSizeMake(177, 205)
            case 414:
                return CGSizeMake(196, 220)
            default:
                return CGSizeMake(150, 180)

        }
        
       
    }
}


