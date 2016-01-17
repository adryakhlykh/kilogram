//
//  InstagramService.swift
//  kilogram
//
//  Created by TeeDee on 05.01.16.
//  Copyright © 2016 TeeDee. All rights reserved.
//

import UIKit
import Locksmith
import CoreData
import Foundation
import SystemConfiguration

class InstagramService: NSObject {
    
    weak var delegate: InstagramServiceDelegate?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    var userCoreData = [NSManagedObject]()
    var imageCoreData = [NSManagedObject]()
    var maxID = ""
    
    
    func getToken()->String {
        var tokenString=""
        if let a = Locksmith.loadDataForUserAccount("instagram"){
            let b = a["Token"] as? String
             tokenString = b!
        }
        return tokenString
    }
   
    
  
  
    
    func authentication() {
        
        let clientId = "02b2bcae954447d0a19b0f0793e85108"
        let redirectURI = "kilogram://"
        let url = NSURL(string: "https://api.instagram.com/oauth/authorize/?client_id=\(clientId)&redirect_uri=\(redirectURI)&response_type=token&scope=basic+public_content+likes")
        
        UIApplication.sharedApplication().openURL(url!)
        
    }
    
        
    
    
    func loadMedia(refresh:String) {
        let tokenString = getToken()
        let urls = ["media/recent/",""]
        var count = 5
        var loadCount = 5
        
        for loadCount=5;loadCount<=20;loadCount++ {
        
        if imageCoreData.count == loadCount {
            self.maxID = (imageCoreData[loadCount-1].valueForKey("maxID") as? String)!
            }
        }
        if refresh == "refresh" {
            self.maxID = ""
                count = imageCoreData.count
            
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)
            for u in urls {
                let url = NSURL(string: "https://api.instagram.com/v1/users/self/\(u)?access_token=\(tokenString)&count=\(count)&max_id=\(self.maxID)")
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "GET"
                
                    let dataTask = session.dataTaskWithRequest(request) { (data, response,error) -> Void in
                        if data != nil {
                            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                            if let jsonData = json["data"] {
                                if u == urls[0] {
                                    let max = json["pagination"]?.valueForKey("next_max_id")
                                    
                                    
                                    if max != nil  {
                                        self.maxID = max as! String
                                    }
                                    var i=0
                                    for  j in jsonData as! NSArray {
                                        let picURLString = j.valueForKeyPath("images.standard_resolution.url") as! String
                                        let urlData = self.convertURLToData(picURLString)
                                        let likes = (j.valueForKeyPath("likes.count")?.description)! as String
                                        let comments = (j.valueForKeyPath("comments.count")?.description)! as String
                                        let picID = j.valueForKey("id") as! String
                                        let text = j.valueForKeyPath("caption.text")?.description
                                        
                                          let imageDict = ["picURL":urlData,"likes":likes,"comments":comments,"picID":picID,"text":text!,"maxID":self.maxID]
                                        if refresh == "refresh" {
                                            
                                                self.update(imageDict,index: i,entityName: "Image")
                                                i++
                                                
                                            
                                        } else {
                                            self.saveData(imageDict,entityName: "Image")
                                        }
                                        
                                    }
                                }
                                else {
                                    let avatarURLString = jsonData.valueForKey("profile_picture") as! String
                                    let urlData = self.convertURLToData(avatarURLString)
                                    let username = jsonData.valueForKey("username") as! String
                                    let fullName = jsonData.valueForKey("full_name") as! String
                                    let counts = jsonData.valueForKey("counts")
                                    let media = (counts!.valueForKey("media")?.description)! as String
                                    let follow = (counts!.valueForKey("follows")?.description)! as String
                                    let followers = (counts!.valueForKey("followed_by")?.description)! as String
                                  
                                    
                                    let userDict:[String : AnyObject] = ["avatar": urlData,"username":username,"fullName": fullName, "media":media,"follow":follow,"followers":followers]
                                    
                                    if refresh == "refresh" {
                                        self.update(userDict,index: 0,entityName: "User")
                                        
                                    } else {
                                        self.saveData(userDict,entityName: "User")
                                    }
                                }
                        
                            }
                        }
                    }
                    dataTask.resume()
                
            }
        }

    }
    
    func saveData(dict:[String : AnyObject], entityName:String) {
        if (self.imageCoreData.count < 20)  { //заглушка на 20 фото из за лимитов инстаграмма
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName(entityName,inManagedObjectContext:managedContext)
        
        
        let picture = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        picture.setValuesForKeysWithDictionary(dict)
            do {
                try managedContext.save()
            }
            catch {
            }

        
        
        }
        fetchData()
    }
    
    func fetchData() {
        let managedContext = appDelegate.managedObjectContext
        let userRequest = NSFetchRequest(entityName:"User")
        let imageRequest = NSFetchRequest(entityName: "Image")
        
        
        
        
        do {
            let userResults = try managedContext.executeFetchRequest(userRequest) as? [NSManagedObject]
            let imageResults = try managedContext.executeFetchRequest(imageRequest) as? [NSManagedObject]
          
            userCoreData = userResults!
            imageCoreData = imageResults!
            self.delegate?.userCoreData(userCoreData)
            self.delegate?.imageCoreData(imageCoreData)
        } catch {}
    }
        
    func update(dict:[String:AnyObject],index:Int,entityName:String) {
        let managedContext = appDelegate.managedObjectContext
        let Request = NSFetchRequest(entityName: entityName)
        
        
        
        do {
            let Results = try managedContext.executeFetchRequest(Request) as? [NSManagedObject]
            let obj = Results![index]
            obj.setValuesForKeysWithDictionary(dict)
            try managedContext.save()
            if entityName == "Image" {
                imageCoreData = Results!
                self.delegate?.imageCoreData(imageCoreData)
                self.maxID = dict["maxID"] as! String

            } else {
                userCoreData = Results!
                self.delegate?.userCoreData(userCoreData)
            }
        } catch {}
        
        
        
        
    }
    
    
    
    
    func convertURLToData(stringURL:String)->NSData {
        
        let url = NSURL(string: stringURL)
        let urlData = NSData(contentsOfURL: url!)
        return urlData!
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
    }
    
    
    func quit() {
        do {
            try Locksmith.deleteDataForUserAccount("instagram")
        }
        catch {
            
        }
    }
    
    
}
    
    




protocol InstagramServiceDelegate:class {
    func userCoreData(_:[NSManagedObject])
    func imageCoreData(_:[NSManagedObject])
}
