//
//  Tweet.swift
//  TwitterSearch
//
//  Created by Suhit P on 30/06/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//

import UIKit

struct Tweet {
  let name: String
  let profileImageUrl: String
  let screenName: String
  let id: Int
  let text: String
}

extension Tweet {
  
  init?(json: [String: AnyObject]) {
    
    self.id = json["id"] as! Int
    self.text = json["text"] as! String
    self.name = json["user"]!["name"] as! String
    self.profileImageUrl = json["user"]!["profile_image_url_https"] as! String
    self.screenName = json["user"]!["screen_name"] as! String
    
    guard !name.isEmpty && !profileImageUrl.isEmpty && !screenName.isEmpty && !text.isEmpty else {
      return nil
    }
    
  }
  
}