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
  
  init() {
    Twitter.sharedInstance().startWithConsumerKey(consumerKey, consumerSecret: secret)
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
          let tweets = tweetArray.flatMap(Tweet.init)
          dispatch_async(dispatch_get_main_queue(), { 
            completion(result: tweets)
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
