//
//  NetworkAPIClient.swift
//  TwitterSearch
//
//  Created by Suhit P on 29/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit
import TwitterKit


struct NetworkAPIClient {
  
  let url = "https://api.twitter.com/1.1/search/tweets.json"
  let consumerKey = "R6yWPRlg2WHgrwQdqMSNATHzM"
  let secret = "rfEsLFawxA1fa6RQiTPRZDP5h8gQuEzOuoQjY53nmXAQ0rnnff"
  let client = TWTRAPIClient()
  var coreDataController: CoreDataController!
  
    init(coreDataController: CoreDataController) {
        Twitter.sharedInstance().startWithConsumerKey(consumerKey, consumerSecret: secret)
        self.coreDataController = coreDataController
    }
  
    func loadTweetsForHashtag(hashTag: String, maxId: Int?, completion: (result: [Tweet]?) -> ()) {
  
      var params: [String: String] = ["q":"#iOS", "result_type": "mixed", "count": "50"]
      if let maxId = maxId {
           params["max_id"] = String(maxId)
      }
        
      let request = client.URLRequestWithMethod("GET", URL: url, parameters: params, error: nil)
        
      client.sendTwitterRequest(request) { (response, data, error) in
    
      if let error = error {
        print("error: \(error.localizedDescription)")
        return
      }
        
      do {
        let json  = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
        print(json)
        if let tweetArray = (json["statuses"] as? [[String: AnyObject]]) {
            
            var tweets = [Tweet]()
            for json in tweetArray {
                
                let tweetEntity = NSEntityDescription.entityForName("Tweet", inManagedObjectContext:self.coreDataController.managedObjectContext)
                let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.coreDataController.managedObjectContext)
                
                let tweet = Tweet(entity: tweetEntity!, insertIntoManagedObjectContext: self.coreDataController.managedObjectContext)
                tweet.setValue(json["id"] as! NSNumber, forKey: "id")
                tweet.setValue(json["text"] as! String, forKey: "text")
                
                let user = User(entity: userEntity!, insertIntoManagedObjectContext: self.coreDataController.managedObjectContext)
                user.setValue(json["user"]!["name"] as! String, forKey: "name")
                user.setValue(json["user"]!["screen_name"] as! String, forKey: "screenName")
                user.setValue(json["user"]!["profile_image_url_https"], forKey: "profileImageUrl")
                
                tweet.setValue(user, forKey: "user")
                
                do {
                    try self.coreDataController.managedObjectContext.save()
                    tweets.append(tweet)
                    completion(result: tweets)
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(result: nil)
            })
          
        } else {
          dispatch_async(dispatch_get_main_queue(), {
            completion(result: nil)
          })
        }
      } catch let error as NSError {
        print("Fetch failed: \(error.localizedDescription)")
      }
    }
  }

}
