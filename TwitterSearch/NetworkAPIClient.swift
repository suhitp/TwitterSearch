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
  
  func loadTweetsForHashtag(hashTag: String, completion: (result: [Tweet]?) -> ()) {
  
    let request = client.URLRequestWithMethod("GET", URL: url, parameters: ["q":"#iOS", "count": "20"], error: nil)
    client.sendTwitterRequest(request) { (response, data, error) in
    
      do {
        let json  = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
        if let tweetArray = (json["statuses"] as? [[String: AnyObject]]) {
          print(tweetArray)
          let tweets = tweetArray.flatMap(Tweet.init)
          completion(result: tweets)
        } else {
          completion(result: nil)
        }
      } catch let error as NSError {
        print("Fetch failed: \(error.localizedDescription)")
      }
      
    }
  }

}
